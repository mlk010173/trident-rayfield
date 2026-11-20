import express from 'express';
import path from 'node:path';
import { createServer as createViteServer } from 'vite';
import { analyzeLolVm, analyzeWadLift, analyzeWeAreDevs } from './server/analyzers';
import { createConfigStore, getArtifacts } from './server/artifacts';

async function startServer() {
  const app = express();
  const PORT = Number(process.env.PORT) || 3000;
  const isProd = process.env.NODE_ENV === 'production';

  app.use(express.json({ limit: '4mb' }));

  const artifacts = getArtifacts();
  const configStore = createConfigStore(artifacts.uiSchema);

  app.get('/api/overview', (_req, res) => {
    res.json({
      overview: artifacts.overview,
      reports: Object.entries(artifacts.reports).map(([id, r]) => ({
        id,
        title: r.title,
        subtitle: r.subtitle,
      })),
      samplePayloads: artifacts.samplePayloads,
    });
  });

  app.get('/api/reports/:id', (req, res) => {
    const report = artifacts.reports[req.params.id];
    if (!report) {
      return res.status(404).json({ error: 'Report not found' });
    }
    res.json({ id: req.params.id, ...report });
  });

  app.get('/api/strings', (req, res) => {
    const corpusKey = String(req.query.corpus || 'recovery') as keyof typeof artifacts.corpora;
    const corpus = artifacts.corpora[corpusKey];
    if (!corpus) {
      return res.status(400).json({ error: 'Invalid corpus. Expected avox, recovery, or trident_v4.' });
    }
    const query = String(req.query.q || '').trim().toLowerCase();
    const category = String(req.query.category || 'All');
    const page = Math.max(1, parseInt(String(req.query.page || '1'), 10) || 1);
    const limit = Math.min(100, Math.max(10, parseInt(String(req.query.limit || '50'), 10) || 50));

    let filtered = corpus;
    if (category !== 'All') {
      filtered = filtered.filter((entry) => entry.category === category);
    }
    if (query) {
      filtered = filtered.filter((entry) => entry.value.toLowerCase().includes(query));
    }

    const total = filtered.length;
    const totalPages = Math.max(1, Math.ceil(total / limit));
    const safePage = Math.min(page, totalPages);
    const start = (safePage - 1) * limit;
    const items = filtered.slice(start, start + limit);

    const categoryCounts: Record<string, number> = {
      All: corpus.length,
      URL: 0,
      'Service / Path': 0,
      'UI / Flag': 0,
      'Network / Hook': 0,
      Constant: 0,
    };
    for (const item of corpus) {
      categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
    }

    res.json({
      corpus: corpusKey,
      total,
      page: safePage,
      limit,
      totalPages,
      categoryCounts,
      items,
    });
  });

  app.get('/api/ui-schema', (_req, res) => {
    res.json({
      tabs: artifacts.uiSchema,
      avoxMenu: artifacts.avoxMenu,
    });
  });

  app.get('/api/configs', (_req, res) => {
    res.json({
      presets: Array.from(configStore.values()),
    });
  });

  app.post('/api/configs', (req, res) => {
    const name = String(req.body?.name || '').trim();
    const description = String(req.body?.description || 'Custom user preset').trim();
    const values = req.body?.values;
    if (!name || typeof values !== 'object' || values === null) {
      return res.status(400).json({ error: 'Preset name and values object are required.' });
    }
    const preset = {
      name,
      description,
      updatedAt: new Date().toISOString(),
      values: values as Record<string, unknown>,
    };
    configStore.set(name, preset);
    res.status(201).json({ preset });
  });

  app.delete('/api/configs/:name', (req, res) => {
    const name = req.params.name;
    if (name === 'default') {
      return res.status(400).json({ error: 'Default preset cannot be deleted.' });
    }
    if (!configStore.has(name)) {
      return res.status(404).json({ error: 'Preset not found.' });
    }
    configStore.delete(name);
    res.json({ deleted: name });
  });

  app.post('/api/analyze/wad', (req, res) => {
    const source = String(req.body?.source || '');
    if (!source.trim()) {
      return res.status(400).json({ error: 'Input Lua source is empty.' });
    }
    try {
      res.json(analyzeWadLift(source));
    } catch (err) {
      res.status(400).json({ error: err instanceof Error ? err.message : 'WAD analysis failed' });
    }
  });

  app.post('/api/analyze/lol', (req, res) => {
    const source = String(req.body?.source || '');
    if (!source.trim()) {
      return res.status(400).json({ error: 'Input payload is empty.' });
    }
    try {
      res.json(analyzeLolVm(source));
    } catch (err) {
      res.status(400).json({ error: err instanceof Error ? err.message : 'LOL! VM decode failed' });
    }
  });

  app.post('/api/analyze/wearedevs', (req, res) => {
    const source = String(req.body?.source || '');
    if (!source.trim()) {
      return res.status(400).json({ error: 'Input Lua source is empty.' });
    }
    try {
      res.json(analyzeWeAreDevs(source));
    } catch (err) {
      res.status(400).json({ error: err instanceof Error ? err.message : 'WeAreDevs decode failed' });
    }
  });

  if (isProd) {
    const distDir = path.join(process.cwd(), 'dist');
    app.use(express.static(distDir));
    app.get('*', (_req, res) => {
      res.sendFile(path.join(distDir, 'index.html'));
    });
  } else {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    app.use(vite.middlewares);
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Trident Analysis Workbench listening on http://0.0.0.0:${PORT}`);
  });
}

startServer();

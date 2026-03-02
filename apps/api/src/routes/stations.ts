import { Hono } from 'hono';
import { createDbClient } from '../db/client';
import { StationRepository } from '../db/queries';
import type { Bindings, Variables } from '../index';

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

app.get('/current', async (c) => {
  const stationId = c.get('stationId');

  if (!stationId) {
    return c.json({ error: 'No station assigned' }, 404);
  }

  const db = createDbClient(c.env.DB);
  const stationRepo = new StationRepository(db);

  const station = await stationRepo.findById(stationId);

  if (!station) {
    return c.json({ error: 'Station not found' }, 404);
  }

  return c.json({ station });
});

app.get('/', async (c) => {
  const db = createDbClient(c.env.DB);
  const stationRepo = new StationRepository(db);

  const stations = await stationRepo.findAll();

  return c.json({ stations });
});

app.get('/:id', async (c) => {
  const id = c.req.param('id');

  const db = createDbClient(c.env.DB);
  const stationRepo = new StationRepository(db);

  const station = await stationRepo.findById(id);

  if (!station) {
    return c.json({ error: 'Station not found' }, 404);
  }

  return c.json({ station });
});

export default app;

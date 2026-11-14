import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL;
const N = parseInt(__ENV.N || '50');

export const options = {
  stages: [
    { duration: '2m', target: N },
    { duration: '5m', target: N },
    { duration: '2m', target: 0 },
  ],
  summaryTrendStats: ['avg', 'med', 'p(95)', 'p(99)', 'max'],
};

const headers = { 'Content-Type': 'application/json' };

export default function () {
  const created = http.post(
    `${BASE_URL}/api/notes`,
    JSON.stringify({ title: `note ${__VU}-${__ITER}` }),
    { headers, tags: { name: 'POST /api/notes' } }
  );
  check(created, { 'created 201': (r) => r.status === 201 });
  const id = created.status === 201 ? created.json('id') : 1;

  for (let i = 0; i < 3; i++) {
    const list = http.get(`${BASE_URL}/api/notes`, { tags: { name: 'GET /api/notes' } });
    check(list, { 'list 200': (r) => r.status === 200 });
    const one = http.get(`${BASE_URL}/api/notes/${id}`, { tags: { name: 'GET /api/notes/:id' } });
    check(one, { 'by id 200': (r) => r.status === 200 });
  }
  for (let i = 0; i < 3; i++) {
    const old = http.get(`${BASE_URL}/api/notes/${Math.max(1, id - 1 - i)}`, { tags: { name: 'GET /api/notes/:id' } });
    check(old, { 'old note 200/404': (r) => r.status === 200 || r.status === 404 });
  }
}

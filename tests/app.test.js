const request = require('supertest');
const app = require('../src/app');

describe('Endpoints Web API & Health Check', () => {
  it('GET / harus mengembalikan metadata aplikasi dan status 200', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('service', 'fargate-web-api');
    expect(res.body).toHaveProperty('status', 'running');
  });

  it('GET /health harus mengembalikan status healthy untuk ALB/ECS Health Check', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('status', 'healthy');
    expect(res.body).toHaveProperty('timestamp');
  });
});

import { api } from './api';

export async function enhanceProductPhoto(file) {
  const formData = new FormData();
  formData.append('file', file);
  return api('/products/enhance-photo', {
    method: 'POST',
    body: formData,
    headers: {},
  });
}

export function findBuyerMatches(criteria) {
  return api('/linkages/match', {
    method: 'POST',
    body: JSON.stringify(criteria),
  });
}

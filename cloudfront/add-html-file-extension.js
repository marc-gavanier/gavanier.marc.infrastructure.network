function handler(event) {
  if (event.request.uri === '/') return event.request
  if (event.request.uri.endsWith('/')) event.request.uri = event.request.uri.replace(/\/$/,".html");
  else if (!event.request.uri.includes('.')) event.request.uri = `${event.request.uri}.html`;

  return event.request
}

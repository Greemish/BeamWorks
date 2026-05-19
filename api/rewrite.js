import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default function handler(req, res) {
  const { pathname } = new URL(req.url, `http://${req.headers.host}`);
  
  // Map routes to HTML files
  const routeMap = {
    '/admin': 'Admin.html',
    '/Admin': 'Admin.html',
    '/shop': 'shop.html',
    '/product': 'product.html',
    '/checkout': 'checkout.html',
    '/promotions': 'promotions.html',
    '/homepage': 'Homepage.html',
  };
  
  // Check if route exists in map
  const htmlFile = routeMap[pathname];
  
  if (htmlFile) {
    try {
      const filePath = path.join(__dirname, '..', 'Frontend', htmlFile);
      const content = fs.readFileSync(filePath, 'utf-8');
      res.setHeader('Content-Type', 'text/html');
      res.status(200).send(content);
      return;
    } catch (error) {
      console.error(`Error reading ${htmlFile}:`, error);
      res.status(500).send('Internal Server Error');
      return;
    }
  }
  
  // If no route matches, return 404
  res.status(404).send('Not found');
}

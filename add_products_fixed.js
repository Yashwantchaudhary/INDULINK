const http = require('http');

const BASE_URL = 'http://localhost:5000/api';

// Sample categories
const categories = [
  { name: "Steel & Metal", description: "Steel products and metal materials" },
  { name: "Cement & Concrete", description: "Cement, concrete and masonry products" },
  { name: "Aggregates", description: "Sand, gravel and aggregate materials" },
  { name: "Bricks & Blocks", description: "Bricks, blocks and masonry units" },
  { name: "Pipes & Fittings", description: "Pipes, fittings and plumbing materials" },
  { name: "Electrical", description: "Electrical wires, cables and components" },
  { name: "Paints & Finishes", description: "Paints, coatings and finishing materials" },
  { name: "Hardware", description: "Hardware, tools and fasteners" },
  { name: "Roofing", description: "Roofing materials and accessories" },
  { name: "Windows & Doors", description: "Windows, doors and related hardware" }
];

// Sample hardware products
const products = [
  {
    title: "Steel Rebar 12mm",
    description: "High-quality steel reinforcement bars for construction",
    price: 85.50,
    stock: 500,
    images: [{ url: "https://example.com/rebar.jpg", alt: "Steel Rebar 12mm", isPrimary: true }]
  },
  {
    title: "Cement 50kg Bag",
    description: "Portland cement for concrete construction",
    price: 12.75,
    stock: 1000,
    images: [{ url: "https://example.com/cement.jpg", alt: "Cement 50kg Bag", isPrimary: true }]
  },
  {
    title: "Sand 1 Cubic Meter",
    description: "Construction sand for plastering and masonry",
    price: 45.00,
    stock: 200,
    images: [{ url: "https://example.com/sand.jpg", alt: "Sand 1 Cubic Meter", isPrimary: true }]
  },
  {
    title: "Bricks Red Clay 1000pcs",
    description: "Standard red clay bricks for wall construction",
    price: 8.50,
    stock: 5000,
    images: [{ url: "https://example.com/bricks.jpg", alt: "Bricks Red Clay 1000pcs", isPrimary: true }]
  },
  {
    title: "PVC Pipes 4 inch",
    description: "PVC drainage pipes for plumbing systems",
    price: 15.25,
    stock: 300,
    images: [{ url: "https://example.com/pvc-pipes.jpg", alt: "PVC Pipes 4 inch", isPrimary: true }]
  },
  {
    title: "Electrical Wire 2.5mm",
    description: "Copper electrical wire for house wiring",
    price: 3.20,
    stock: 1000,
    images: [{ url: "https://example.com/wire.jpg", alt: "Electrical Wire 2.5mm", isPrimary: true }]
  },
  {
    title: "Paint Emulsion 20L",
    description: "Premium emulsion paint for interior walls",
    price: 85.00,
    stock: 150,
    images: [{ url: "https://example.com/paint.jpg", alt: "Paint Emulsion 20L", isPrimary: true }]
  },
  {
    title: "Door Hardware Set",
    description: "Complete door hardware kit with lock and hinges",
    price: 45.75,
    stock: 75,
    images: [{ url: "https://example.com/door-hardware.jpg", alt: "Door Hardware Set", isPrimary: true }]
  },
  {
    title: "Roofing Sheets 10ft",
    description: "Corrugated roofing sheets for industrial buildings",
    price: 125.00,
    stock: 100,
    images: [{ url: "https://example.com/roofing.jpg", alt: "Roofing Sheets 10ft", isPrimary: true }]
  },
  {
    title: "Glass Windows 4x4ft",
    description: "Aluminum frame glass windows for residential use",
    price: 285.00,
    stock: 25,
    images: [{ url: "https://example.com/windows.jpg", alt: "Glass Windows 4x4ft", isPrimary: true }]
  }
];

async function addProducts() {
  console.log('🚀 Setting up InduLink with categories and products...\n');

  // First, register/login as supplier to get token
  try {
    console.log('📝 Registering supplier account...');

    const registerResponse = await makeRequest({
      path: '/auth/register',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    }, {
      firstName: 'Hardware',
      lastName: 'Supplier',
      email: `hardware${Date.now()}@supplier.com`,
      password: 'Password123!',
      phone: '9876543210',
      role: 'supplier',
      businessName: 'Hardware Solutions Ltd',
      businessDescription: 'Leading supplier of construction hardware and building materials'
    });

    if (registerResponse.statusCode === 201) {
      console.log('✅ Supplier registered successfully!');
      console.log('🔑 Access Token:', registerResponse.body.data.accessToken.substring(0, 50) + '...');

      const token = registerResponse.body.data.accessToken;

      // Create categories
      console.log('\n📂 Creating categories...');
      const categoryIds = [];

      for (let i = 0; i < categories.length; i++) {
        const category = categories[i];

        try {
          const categoryResponse = await makeRequest({
            path: '/categories',
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`
            },
          }, category);

          if (categoryResponse.statusCode === 201) {
            categoryIds.push(categoryResponse.body.data._id);
            console.log(`✅ Created category: ${category.name}`);
          } else {
            console.log(`❌ Failed to create category: ${category.name}`);
          }
        } catch (error) {
          console.log(`❌ Error creating category ${category.name}: ${error.message}`);
        }
      }

      // Add products
      console.log('\n📦 Adding products...');

      for (let i = 0; i < products.length; i++) {
        const product = { ...products[i], category: categoryIds[i] };

        try {
          const productResponse = await makeRequest({
            path: '/products',
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`
            },
          }, product);

          if (productResponse.statusCode === 201) {
            console.log(`✅ Added: ${product.title} (₹${product.price})`);
          } else {
            console.log(`❌ Failed: ${product.title} - ${productResponse.body?.message || 'Unknown error'}`);
          }
        } catch (error) {
          console.log(`❌ Error adding ${product.title}: ${error.message}`);
        }

        // Small delay to avoid overwhelming the server
        await new Promise(resolve => setTimeout(resolve, 500));
      }

      console.log('\n🎉 Setup completed successfully!');
      console.log('📊 Total categories created: 10');
      console.log('📦 Total products added: 10');
      console.log('🏪 Supplier: Hardware Solutions Ltd');

    } else {
      console.log('❌ Registration failed:', registerResponse.body?.message);
    }

  } catch (error) {
    console.log('❌ Error:', error.message);
  }
}

function makeRequest(options, data = null) {
  return new Promise((resolve, reject) => {
    const fullUrl = BASE_URL + options.path;
    const url = new URL(fullUrl);
    const protocol = url.protocol === 'https:' ? require('https') : http;

    const reqOptions = {
      hostname: url.hostname,
      port: url.port || (url.protocol === 'https:' ? 443 : 80),
      path: url.pathname + url.search,
      method: options.method || 'GET',
      headers: options.headers || {},
    };

    const req = protocol.request(reqOptions, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const response = {
            statusCode: res.statusCode,
            headers: res.headers,
            body: body ? JSON.parse(body) : null,
          };
          resolve(response);
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            body: body,
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
}

// Run the script
addProducts().catch(console.error);
import { useEffect, useMemo, useState } from 'react';
import { ArrowLeft, ArrowRight, Compass, Hammer, MapPin, Menu, Search, Store, UserRound, Users, X } from 'lucide-react';
import { endpoints } from './api';

const categories = [
  { id: 'kalamkari', name: 'Kalamkari Sarees', eyebrow: 'HAND-PAINTED TEXTILES', description: 'Story-rich cotton and silk sarees painted with natural dyes and patient hands.', tone: 'terracotta', mark: 'K', cover: '/images/catalog/sarees/sarees.webp' },
  { id: 'sikki', name: 'Sikki Grass Products', eyebrow: 'GOLDEN GRASS CRAFT', description: 'Light-catching baskets, boxes, and home objects woven from Bihar’s golden grass.', tone: 'saffron', mark: 'S', cover: '/images/catalog/Sikki%20Grass/Sikki%20Grass.jpeg' },
  { id: 'kondapalli', name: 'Kondapalli Bommalu', eyebrow: 'LIGHTWOOD STORIES', description: 'Hand-carved Andhra Pradesh toys that bring folklore, festivals, and village life home.', tone: 'teal', mark: 'K', cover: '/images/catalog/kondapalli/kondapalli.jpg' },
  { id: 'forest', name: 'Raw Forest Harvest', eyebrow: 'FROM THE LIVING FOREST', description: 'Honey, berries, spices, and other seasonal harvests gathered with care.', tone: 'moss', mark: 'F', cover: '/images/catalog/harvesting/honey.jpg' },
];

const categoryImages = {
  forest: ['honey.jpg', 'honey1.webp', 'honey2.webp', 'honey3.avif', 'honey4.jpg', 'honey5.jpg', 'images.jpg'].map((file) => `/images/catalog/harvesting/${file}`),
  kondapalli: ['kondapalli.jpg', 'kondapalli1.jpg', 'kondapalli2.webp', 'kondapalli3.webp', 'kondapalli4.jpg', 'kondapalli5.webp', 'kondapalli6.webp'].map((file) => `/images/catalog/kondapalli/${file}`),
  kalamkari: ['sarees.webp', 'sarees1.webp', 'sarees2.jpg', 'sarees2.webp', 'sarees3.jpg', 'sarees4.webp', 'sarees5.jpg'].map((file) => `/images/catalog/sarees/${file}`),
  sikki: ['Sikki Grass.jpeg', 'Sikki Grass1.jpg', 'Sikki Grass2.jpg', 'Sikki Grass3.jpg', 'Sikki Grass4.jpg', 'Sikki Grass5.jpg', 'Sikki Grass6.jpg'].map((file) => `/images/catalog/Sikki%20Grass/${file}`),
};

const productImages = {
  'kal-1': categoryImages.kalamkari[0],
  'kal-2': categoryImages.kalamkari[1],
  'sik-1': categoryImages.sikki[0],
  'sik-2': categoryImages.sikki[1],
  'kon-1': categoryImages.kondapalli[0],
  'kon-2': categoryImages.kondapalli[1],
  'for-1': categoryImages.forest[0],
  'for-2': categoryImages.forest[1],
  'for-3': categoryImages.forest[2]
};

const artisans = [
  { id: 'lakshmi', name: 'Lakshmi Devi', place: 'Machilipatnam, Andhra Pradesh', craft: 'Kalamkari artist', story: 'Lakshmi is a third-generation Kalamkari painter preserving the old vegetable-dye rituals of coastal Andhra.', artisanId: 'lakshmi' },
  { id: 'sunita', name: 'Sunita Kumari', place: 'Madhubani, Bihar', craft: 'Sikki grass weaver', story: 'Sunita works with a women-led collective, turning locally gathered golden grass into useful everyday objects.', artisanId: 'sunita' },
  { id: 'venkatesh', name: 'Venkatesh Rao', place: 'Kondapalli, Andhra Pradesh', craft: 'Wooden toy maker', story: 'Venkatesh carves soft Tella Poniki wood into characters from stories his grandfather told him as a child.', artisanId: 'venkatesh' },
  { id: 'meera', name: 'Meera Hembram', place: 'Mayurbhanj, Odisha', craft: 'Forest harvest collective', story: 'Meera coordinates a seasonal forest harvest collective that makes sure local knowledge remains visible in every basket and jar.', artisanId: 'meera' },
];

const products = [
  { id: 'kal-1', category: 'kalamkari', artisanId: 'lakshmi', name: 'River of Stories Kalamkari Saree', description: 'A hand-painted cotton saree tracing river birds, vines, and village scenes in deep indigo and rust.', materials: 'Cotton, natural dyes', price: 4200 },
  { id: 'kal-2', category: 'kalamkari', artisanId: 'lakshmi', name: 'Peacock Garden Silk Saree', description: 'A soft silk-cotton drape with a border of hand-drawn peacocks and flowering creepers.', materials: 'Silk cotton, mineral dye', price: 5100 },
  { id: 'sik-1', category: 'sikki', artisanId: 'sunita', name: 'Golden Moon Storage Basket', description: 'A lidded grass basket for keepsakes, finished with a bold spiral weave and cotton trim.', materials: 'Sikki grass, cotton yarn', price: 1800 },
  { id: 'sik-2', category: 'sikki', artisanId: 'sunita', name: 'Harvest Weave Table Set', description: 'A set of handwoven coasters and a serving tray that bring the warmth of the harvest indoors.', materials: 'Sikki grass, jute', price: 2400 },
  { id: 'kon-1', category: 'kondapalli', artisanId: 'venkatesh', name: 'Village Market Bommallu Set', description: 'A cheerful hand-carved scene of a village market, painted one character at a time.', materials: 'Tella Poniki wood, natural paint', price: 2600 },
  { id: 'kon-2', category: 'kondapalli', artisanId: 'venkatesh', name: 'Dancing Gollabhama Doll', description: 'A bright folk figure inspired by the traditional women of Kondapalli village life.', materials: 'Softwood, vegetable colours', price: 2100 },
  { id: 'for-1', category: 'forest', artisanId: 'meera', name: 'Wildflower Forest Honey', description: 'Small-batch raw honey gathered from flowering forest edges and strained without heat.', materials: 'Raw forest honey', price: 950 },
  { id: 'for-2', category: 'forest', artisanId: 'meera', name: 'Sun-Dried Mahua Berry Mix', description: 'A fragrant seasonal harvest with deep caramel notes, dried naturally by the collective.', materials: 'Mahua fruit, forest berries', price: 1200 },
  { id: 'for-3', category: 'forest', artisanId: 'meera', name: 'Wild Turmeric & Pepper Box', description: 'A fragrant kitchen set of sun-dried forest spices, packed close to their source.', materials: 'Wild turmeric, black pepper', price: 1100 },
];

const formatINR = (value) => new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(value);

function VoiceSearchWidget({ value, onChange }) {
  const [listening, setListening] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
      setError('Voice search is not supported in this browser. Use Chrome or Edge.');
      return undefined;
    }

    const recognition = new SpeechRecognition();
    recognition.lang = 'en-US';
    recognition.interimResults = false;
    recognition.maxAlternatives = 1;

    recognition.onstart = () => setListening(true);
    recognition.onend = () => setListening(false);
    recognition.onerror = (event) => {
      setError(`Voice input error: ${event.error}`);
      setListening(false);
    };
    recognition.onresult = (event) => {
      const transcript = event.results[0][0].transcript;
      onChange(transcript);
    };

    window.__artisanConnectVoiceRecognition = recognition;

    return () => {
      recognition.stop();
      delete window.__artisanConnectVoiceRecognition;
    };
  }, [onChange]);

  const startListening = () => {
    const recognition = window.__artisanConnectVoiceRecognition;
    if (!recognition) return;

    try {
      setError('');
      recognition.start();
    } catch (e) {
      setError('Microphone is already in use. Please try again.');
    }
  };

  return (
    <div style={{ marginBottom: 18, display: 'flex', gap: 10, alignItems: 'center', flexWrap: 'wrap' }}>
      <input
        type="text"
        value={value}
        onChange={(event) => onChange(event.target.value)}
        placeholder="Search craft, artisan, or product..."
        style={{ flex: 1, minWidth: 220, padding: '10px 12px', borderRadius: 10, border: '1px solid #d7d0c7', fontSize: 15 }}
      />
      <button type="button" onClick={startListening} style={{ padding: '10px 14px', borderRadius: 10, border: 'none', background: '#1a3a2f', color: '#fff', cursor: 'pointer' }}>
        {listening ? 'Listening...' : '🎙️ Voice'}
      </button>
      {error && <span style={{ color: '#b42318', fontSize: 13 }}>{error}</span>}
    </div>
  );
}

function App() {
  return <Marketplace />;
}

function Marketplace() {
  const [view, setView] = useState({ page: 'home' });
  const [search, setSearch] = useState('');
  const [mobileOpen, setMobileOpen] = useState(false);
  const filteredProducts = useMemo(() => products.filter((product) => `${product.name} ${product.description} ${product.materials}`.toLowerCase().includes(search.toLowerCase())), [search]);
  const goHome = () => { setView({ page: 'home' }); setMobileOpen(false); };
  const openCategory = (categoryId) => { setView({ page: 'category', categoryId }); setMobileOpen(false); };
  const openProduct = (productId) => { setView({ page: 'product', productId }); setMobileOpen(false); };
  const openArtisan = (artisanId) => { setView({ page: 'artisan', artisanId }); setMobileOpen(false); };

  return <div className="app-shell">
    <aside className={`sidebar ${mobileOpen ? 'sidebar-open' : ''}`}>
      <div className="brand"><span className="brand-mark"><Hammer size={19} /></span><span>artisan<br /><strong>connect</strong></span></div>
      <p className="eyebrow">THE MAKER'S EXCHANGE</p>
      <nav><button className={`nav-button ${view.page === 'home' || view.page === 'category' || view.page === 'product' ? 'active' : ''}`} onClick={goHome}><Compass size={18} /><span>Discover</span></button><button className={`nav-button ${view.page === 'artisans' ? 'active' : ''}`} onClick={() => { setView({ page: 'artisans' }); setMobileOpen(false); }}><Users size={18} /><span>Artisans</span></button><button className={`nav-button ${view.page === 'artisan' ? 'active' : ''}`} onClick={() => { setView({ page: 'artisans' }); setMobileOpen(false); }}><Store size={18} /><span>Marketplace</span></button></nav>
      <div className="sidebar-footer"><div className="profile-chip"><span className="avatar">G</span><span><b>Guest workspace</b><small>Browse freely</small></span></div></div>
    </aside>
    {mobileOpen && <button className="sidebar-scrim" onClick={() => setMobileOpen(false)} aria-label="Close menu" />}
    <main className="main-content">
      <header className="topbar"><button className="mobile-menu icon-button" onClick={() => setMobileOpen(true)}><Menu size={20} /></button><div><p className="overline">{view.page === 'artisans' ? 'MAKER DIRECTORY' : 'DISCOVER HANDCRAFT'}</p><h1>{view.page === 'artisans' ? 'Artisans' : 'Marketplace'}</h1></div><div className="top-actions"><button className="icon-button" aria-label="Search"><Search size={18} /></button></div></header>
      <VoiceSearchWidget value={search} onChange={setSearch} />
      {view.page === 'home' && <Home search={search} setSearch={setSearch} products={filteredProducts} openCategory={openCategory} openProduct={openProduct} />}
      {view.page === 'category' && <Category categoryId={view.categoryId} products={products.filter((product) => product.category === view.categoryId && filteredProducts.includes(product))} openProduct={openProduct} goHome={goHome} />}
      {view.page === 'product' && <ProductDetail product={products.find((item) => item.id === view.productId)} openArtisan={openArtisan} goBack={() => setView({ page: 'category', categoryId: products.find((item) => item.id === view.productId)?.category || 'kalamkari' })} />}
      {view.page === 'artisans' && <ArtisanDirectory openArtisan={openArtisan} />}
      {view.page === 'artisan' && <ArtisanProfile artisan={artisans.find((item) => item.id === view.artisanId)} openProduct={openProduct} goBack={() => setView({ page: 'artisans' })} />}
    </main>
  </div>;
}

function Home({ search, setSearch, products, openCategory, openProduct }) {
  return <section className="content-section home-page">
    <div className="home-intro">
      <div>
        <span className="section-kicker">A MARKETPLACE FOR LIVING TRADITIONS</span>
        <h2>Made by hand.<br /><em>Carried with story.</em></h2>
      </div>
      <div className="search-card">
        <Search size={18} />
        <input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search handmade products" />
      </div>
    </div>
    <div className="category-grid">
      {categories.map((category) => (
        <button key={category.id} className="category-card" onClick={() => openCategory(category.id)}>
          <div className="card-visual" style={{ backgroundImage: `url(${category.cover})` }} />
          <div className="card-copy">
            <span className="eyebrow mini">{category.eyebrow}</span>
            <h3>{category.name}</h3>
            <p>{category.description}</p>
          </div>
        </button>
      ))}
    </div>
    <div className="product-strip">
      {products.slice(0, 4).map((product) => (
        <article key={product.id} className="product-card" onClick={() => openProduct(product.id)}>
          <div className="product-image" style={{ backgroundImage: `url(${productImages[product.id]})` }} />
          <div className="product-info">
            <span className="product-tag">{product.category}</span>
            <h4>{product.name}</h4>
            <p>{product.description}</p>
            <strong>{formatINR(product.price)}</strong>
          </div>
        </article>
      ))}
    </div>
  </section>;
}

function Category({ categoryId, products: categoryProducts, openProduct, goHome }) {
  const category = categories.find((item) => item.id === categoryId);
  return <section className="content-section">
    <button className="back-link" onClick={goHome}><ArrowLeft size={16} /> All categories</button>
    <div className={`category-hero ${category.tone}`}>
      <span className="section-kicker">{category.eyebrow}</span>
      <h2>{category.name}</h2>
      <p>{category.description}</p>
    </div>
    <div className="product-grid">
      {categoryProducts.map((product) => (
        <article key={product.id} className="product-card" onClick={() => openProduct(product.id)}>
          <div className="product-image" style={{ backgroundImage: `url(${productImages[product.id]})` }} />
          <div className="product-info">
            <h4>{product.name}</h4>
            <p>{product.description}</p>
            <strong>{formatINR(product.price)}</strong>
          </div>
        </article>
      ))}
    </div>
  </section>;
}

function ProductDetail({ product, openArtisan, goBack }) {
  if (!product) return null;
  const artisan = artisans.find((item) => item.id === product.artisanId);
  return <section className="content-section detail-page">
    <button className="back-link" onClick={goBack}><ArrowLeft size={16} /> Back to collection</button>
    <div className="detail-layout">
      <div className="detail-image" style={{ backgroundImage: `url(${productImages[product.id]})` }} />
      <div className="detail-copy">
        <span className="section-kicker">{product.category}</span>
        <h2>{product.name}</h2>
        <p>{product.description}</p>
        <div className="detail-meta">
          <span><MapPin size={16} /> {artisan?.place}</span>
          <span><UserRound size={16} /> {artisan?.name}</span>
        </div>
        <div className="price-row">
          <strong>{formatINR(product.price)}</strong>
          <button className="primary-action" onClick={() => openArtisan(artisan.id)}>Contact artisan</button>
        </div>
      </div>
    </div>
  </section>;
}

function ArtisanDirectory({ openArtisan }) {
  return <section className="content-section artisan-directory">
    <div className="directory-intro">
      <span className="section-kicker">THE MAKER DIRECTORY</span>
      <h2>People, place, and practice.</h2>
      <p>Meet artisans whose products carry the memory of community, craft, and place.</p>
    </div>
    <div className="artisan-grid">
      {artisans.map((artisan) => (
        <article key={artisan.id} className="artisan-card" onClick={() => openArtisan(artisan.id)}>
          <div className="artisan-badge">{artisan.name.split(' ')[0][0]}</div>
          <h3>{artisan.name}</h3>
          <p>{artisan.craft}</p>
          <small>{artisan.place}</small>
        </article>
      ))}
    </div>
  </section>;
}

function ArtisanProfile({ artisan, openProduct, goBack }) {
  const artisanProducts = products.filter((product) => product.artisanId === artisan.id);
  return <section className="content-section artisan-profile">
    <button className="back-link" onClick={goBack}><ArrowLeft size={16} /> All artisans</button>
    <div className="profile-hero">
      <div className="holder-ring"><span>{artisan.name.split(' ')[0][0]}</span></div>
      <div>
        <span className="section-kicker">{artisan.craft}</span>
        <h2>{artisan.name}</h2>
        <p>{artisan.place}</p>
      </div>
    </div>
    <p className="story">{artisan.story}</p>
    <div className="product-grid">
      {artisanProducts.map((product) => (
        <article key={product.id} className="product-card" onClick={() => openProduct(product.id)}>
          <div className="product-image" style={{ backgroundImage: `url(${productImages[product.id]})` }} />
          <div className="product-info">
            <h4>{product.name}</h4>
            <strong>{formatINR(product.price)}</strong>
          </div>
        </article>
      ))}
    </div>
  </section>;
}

export default App;

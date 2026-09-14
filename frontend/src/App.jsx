import { useMemo, useState } from 'react';
import { ArrowLeft, ArrowRight, Compass, Hammer, MapPin, Menu, Search, Store, UserRound, Users, X } from 'lucide-react';
import { endpoints } from './api';

const categories = [
  { id: 'kalamkari', name: 'Kalamkari Sarees', eyebrow: 'HAND-PAINTED TEXTILES', description: 'Story-rich cotton and silk sarees painted with natural dyes and patient hands.', tone: 'terracotta', mark: 'K', coverImage: '/images/front/Klamkari%20sarees.webp' },
  { id: 'sikki', name: 'Sikki Grass Products', eyebrow: 'GOLDEN GRASS CRAFT', description: 'Light-catching baskets, boxes, and home objects woven from Bihar’s golden grass.', tone: 'saffron', mark: 'S', coverImage: '/images/front/sikki%20grass.jpg' },
  { id: 'kondapalli', name: 'Kondapalli Bommalu', eyebrow: 'LIGHTWOOD STORIES', description: 'Hand-carved Andhra Pradesh toys that bring folklore, festivals, and village life home.', tone: 'teal', mark: 'K', coverImage: '/images/front/kondapalli.jpg' },
  { id: 'forest', name: 'Raw Forest Harvest', eyebrow: 'FROM THE LIVING FOREST', description: 'Honey, berries, spices, and other seasonal harvests gathered with care.', tone: 'moss', mark: 'F', coverImage: '/images/front/honey.jpg' }
];

const categoryImages = {
  forest: ['honey.jpg', 'honey1.webp', 'honey2.webp', 'honey3.avif', 'honey4.jpg', 'honey5.jpg', 'images.jpg'].map((file) => `/images/catalog/harvesting/${file}`),
  kondapalli: ['kondapalli.jpg', 'kondapalli1.jpg', 'kondapalli2.webp', 'kondapalli3.webp', 'kondapalli4.jpg', 'kondapalli5.webp', 'kondapalli6.webp'].map((file) => `/images/catalog/kondapalli/${file}`),
  kalamkari: ['sarees.webp', 'sarees1.webp', 'sarees2.jpg', 'sarees2.webp', 'sarees3.jpg', 'sarees4.webp', 'sarees5.jpg'].map((file) => `/images/catalog/sarees/${file}`),
  sikki: ['Sikki Grass.jpeg', 'Sikki Grass1.jpg', 'Sikki Grass2.jpg', 'Sikki Grass3.jpg', 'Sikki Grass4.jpg', 'Sikki Grass5.jpg', 'Sikki Grass6.jpg'].map((file) => `/images/catalog/Sikki%20Grass/${file.replaceAll(' ', '%20')}`)
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
  { id: 'lakshmi', name: 'Lakshmi Devi', place: 'Machilipatnam, Andhra Pradesh', craft: 'Kalamkari artist', story: 'Lakshmi is a third-generation Kalamkari painter preserving the old vegetable-dye stories of the Coromandel coast.', category: 'kalamkari' },
  { id: 'sunita', name: 'Sunita Kumari', place: 'Madhubani, Bihar', craft: 'Sikki grass weaver', story: 'Sunita works with a women-led collective, turning locally gathered golden grass into useful, beautiful forms.', category: 'sikki' },
  { id: 'venkatesh', name: 'Venkatesh Rao', place: 'Kondapalli, Andhra Pradesh', craft: 'Wooden toy maker', story: 'Venkatesh carves soft Tella Poniki wood into characters from stories his grandfather taught him.', category: 'kondapalli' },
  { id: 'meera', name: 'Meera Hembram', place: 'Mayurbhanj, Odisha', craft: 'Forest harvest collective', story: 'Meera coordinates a seasonal forest harvest collective that makes sure local knowledge and fair prices stay together.', category: 'forest' }
];

const products = [
  { id: 'kal-1', category: 'kalamkari', name: 'River of Stories Kalamkari Saree', description: 'A hand-painted cotton saree tracing river birds, vines, and village scenes in deep indigo and rust.', materials: 'Handspun cotton, natural indigo, madder root', price: 4800, artisanId: 'lakshmi', imageTone: 'clay' },
  { id: 'kal-2', category: 'kalamkari', name: 'Peacock Garden Silk Saree', description: 'A soft silk-cotton drape with a border of hand-drawn peacocks and flowering creepers.', materials: 'Silk cotton, iron-black dye, turmeric yellow', price: 7200, artisanId: 'lakshmi', imageTone: 'indigo' },
  { id: 'sik-1', category: 'sikki', name: 'Golden Moon Storage Basket', description: 'A lidded grass basket for keepsakes, finished with a bold spiral weave and cotton trim.', materials: 'Sikki grass, moonj grass, cotton thread', price: 950, artisanId: 'sunita', imageTone: 'gold' },
  { id: 'sik-2', category: 'sikki', name: 'Harvest Weave Table Set', description: 'A set of handwoven coasters and a serving tray that bring the warmth of the harvest indoors.', materials: 'Sikki grass, date palm fiber', price: 1450, artisanId: 'sunita', imageTone: 'wheat' },
  { id: 'kon-1', category: 'kondapalli', name: 'Village Market Bommallu Set', description: 'A cheerful hand-carved scene of a village market, painted one character at a time.', materials: 'Tella Poniki wood, natural pigments, tamarind seed paste', price: 1850, artisanId: 'venkatesh', imageTone: 'coral' },
  { id: 'kon-2', category: 'kondapalli', name: 'Dancing Gollabhama Doll', description: 'A bright folk figure inspired by the traditional women of Kondapalli village life.', materials: 'Softwood, vegetable colors, sawdust paste', price: 780, artisanId: 'venkatesh', imageTone: 'turmeric' },
  { id: 'for-1', category: 'forest', name: 'Wildflower Forest Honey', description: 'Small-batch raw honey gathered from flowering forest edges and strained without heat.', materials: 'Raw forest honey', price: 620, artisanId: 'meera', imageTone: 'amber' },
  { id: 'for-2', category: 'forest', name: 'Sun-Dried Mahua Berry Mix', description: 'A fragrant seasonal harvest with deep caramel notes, dried naturally by the collective.', materials: 'Mahua flowers, wild berries', price: 390, artisanId: 'meera', imageTone: 'berry' },
  { id: 'for-3', category: 'forest', name: 'Wild Turmeric & Pepper Box', description: 'A fragrant kitchen set of sun-dried forest spices, packed close to their source.', materials: 'Wild turmeric, forest pepper, sal leaves', price: 540, artisanId: 'meera', imageTone: 'spice' }
];

const formatINR = (value) => new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(value);

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
      <nav><button className={`nav-button ${view.page === 'home' || view.page === 'category' || view.page === 'product' ? 'active' : ''}`} onClick={goHome}><Compass size={18} /><span>Discover</span></button><button className={`nav-button ${view.page === 'artisans' || view.page === 'artisan' ? 'active' : ''}`} onClick={() => { setView({ page: 'artisans' }); setMobileOpen(false); }}><Users size={18} /><span>Artisans</span></button></nav>
      <div className="sidebar-footer"><div className="profile-chip"><span className="avatar">G</span><span><b>Guest workspace</b><small>Browse freely</small></span></div></div>
    </aside>
    {mobileOpen && <button className="sidebar-scrim" onClick={() => setMobileOpen(false)} aria-label="Close menu" />}
    <main className="main-content">
      <header className="topbar"><button className="mobile-menu icon-button" onClick={() => setMobileOpen(true)}><Menu size={20} /></button><div><p className="overline">{view.page === 'artisans' || view.page === 'artisan' ? 'THE MAKER DIRECTORY' : 'ARTISAN CONNECT'}</p><h1>{view.page === 'home' ? 'Find work with a living story.' : view.page === 'category' ? categories.find((category) => category.id === view.categoryId)?.name : view.page === 'product' ? 'A closer look.' : view.page === 'artisans' ? 'Meet the people behind the work.' : 'A maker, in their own words.'}</h1></div><div className="top-actions"><span className="role-label">Guest browsing</span></div></header>
      {view.page === 'home' && <Home search={search} setSearch={setSearch} products={filteredProducts} openCategory={openCategory} openProduct={openProduct} />}
      {view.page === 'category' && <Category categoryId={view.categoryId} products={products.filter((product) => product.category === view.categoryId && filteredProducts.includes(product))} openProduct={openProduct} goHome={goHome} />}
      {view.page === 'product' && <ProductDetail product={products.find((item) => item.id === view.productId)} openArtisan={openArtisan} openProduct={openProduct} goBack={() => setView({ page: 'category', categoryId: products.find((item) => item.id === view.productId)?.category })} />}
      {view.page === 'artisans' && <ArtisanDirectory openArtisan={openArtisan} />}
      {view.page === 'artisan' && <ArtisanProfile artisan={artisans.find((item) => item.id === view.artisanId)} openProduct={openProduct} goBack={() => setView({ page: 'artisans' })} />}
    </main>
  </div>;
}

function Home({ search, setSearch, products, openCategory, openProduct }) {
  return <section className="content-section home-page"><div className="home-intro"><div><span className="section-kicker">A MARKETPLACE FOR LIVING TRADITIONS</span><h2>Made by hand.<br /><em>Carried forward.</em></h2><p>Discover meaningful objects, textiles, toys, and harvests made by communities who know their craft deeply.</p></div><div className="home-note"><span>01</span><p>Four worlds of making,<br />one thoughtful marketplace.</p></div></div><div className="search-row"><div className="search-field"><Search size={18} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search products, materials, or makers" /><button>Search</button></div></div><div className="category-grid">{categories.map((category, index) => <button className={`category-card ${category.tone} category-delay-${index}`} key={category.id} onClick={() => openCategory(category.id)}><span className="category-photo" style={{ backgroundImage: `url("${category.coverImage}")` }} /><span className="category-label"><h3>{category.name}</h3><ArrowRight size={17} /></span></button>)}</div>{search && <div className="search-results"><div className="panel-heading"><div><span className="section-kicker">SEARCH RESULTS</span><h3>Matching work</h3></div><span className="pill">{products.length} found</span></div><div className="product-grid compact-grid">{products.map((product) => <ProductCard key={product.id} product={product} onOpen={openProduct} />)}</div></div>}</section>;
}

function Category({ categoryId, products: categoryProducts, openProduct, goHome }) {
  const category = categories.find((item) => item.id === categoryId);
  return <section className="content-section"><button className="back-link" onClick={goHome}><ArrowLeft size={16} /> All categories</button><div className={`category-hero ${category.tone}`}><span className="category-mark">{category.mark}</span><div><span className="section-kicker">{category.eyebrow}</span><h2>{category.name}</h2><p>{category.description}</p></div></div><CategoryGallery images={categoryImages[categoryId]} categoryName={category.name} /><div className="section-heading"><div><span className="section-kicker">THE COLLECTION</span><h3>{categoryProducts.length} pieces to explore</h3></div></div><div className="product-grid">{categoryProducts.map((product) => <ProductCard key={product.id} product={product} onOpen={openProduct} />)}</div></section>;
}

function CategoryGallery({ images, categoryName }) {
  return <div className="category-gallery"><div className="gallery-heading"><div><span className="section-kicker">CATEGORY GALLERY</span><h3>Scenes from {categoryName}</h3></div><span>{images.length} reference images</span></div><div className="gallery-grid">{images.map((image) => <div className="gallery-image" key={image}><img src={image} alt={`${categoryName} reference`} /></div>)}</div><p className="gallery-note">These images are matched to this category folder. Product-level image matching will be added when product-specific filenames are available.</p></div>;
}

function ProductCard({ product, onOpen }) {
  return <article className="product-card" onClick={() => onOpen(product.id)}><div className="product-image" style={{ backgroundImage: `url(${productImages[product.id]})` }}><span>{product.category === 'forest' ? 'Forest harvest' : categories.find((category) => category.id === product.category)?.name}</span><button aria-label="Open product"><ArrowRight size={17} /></button></div><div className="product-info"><div><h3>{product.name}</h3><p>{artisans.find((artisan) => artisan.id === product.artisanId)?.name}</p></div><strong>{formatINR(product.price)}</strong></div><div className="product-meta"><span>{product.materials.split(',')[0]}</span><span>View details</span></div></article>;
}

function ProductDetail({ product, openArtisan, goBack }) {
  if (!product) return null;
  const artisan = artisans.find((item) => item.id === product.artisanId);
  return <section className="content-section detail-page"><button className="back-link" onClick={goBack}><ArrowLeft size={16} /> Back to collection</button><div className="detail-layout"><div className="detail-image" style={{ backgroundImage: `url(${productImages[product.id]})` }}><span>Product image</span></div><div className="detail-copy"><span className="section-kicker">{categories.find((category) => category.id === product.category)?.name}</span><h2>{product.name}</h2><p className="detail-description">{product.description}</p><div className="detail-facts"><span><small>Materials</small><b>{product.materials}</b></span><span><small>Price</small><b>{formatINR(product.price)}</b></span></div><div className="artisan-callout"><span className="artisan-avatar"><UserRound size={19} /></span><div><small>MADE BY</small><button onClick={() => openArtisan(artisan.id)}>{artisan.name} <ArrowRight size={14} /></button><p><MapPin size={13} /> {artisan.place}</p></div></div></div></div></section>;
}

function ArtisanDirectory({ openArtisan }) {
  return <section className="content-section artisan-directory"><div className="directory-intro"><span className="section-kicker">THE MAKER DIRECTORY</span><h2>People, place, and practice.</h2><p>Every product starts with a person. Meet the artisans and collectives carrying these traditions forward.</p></div><div className="artisan-grid">{artisans.map((artisan) => <button className="artisan-card" key={artisan.id} onClick={() => openArtisan(artisan.id)}><span className={`artisan-portrait portrait-${artisan.category}`}>{artisan.name[0]}</span><span className="section-kicker">{artisan.craft}</span><h3>{artisan.name}</h3><p><MapPin size={13} /> {artisan.place}</p><span className="card-link">View profile <ArrowRight size={14} /></span></button>)}</div></section>;
}

function ArtisanProfile({ artisan, openProduct, goBack }) {
  const artisanProducts = products.filter((product) => product.artisanId === artisan.id);
  return <section className="content-section artisan-profile"><button className="back-link" onClick={goBack}><ArrowLeft size={16} /> All artisans</button><div className="profile-hero"><span className={`artisan-portrait portrait-${artisan.category}`}>{artisan.name[0]}</span><div><span className="section-kicker">{artisan.craft}</span><h2>{artisan.name}</h2><p><MapPin size={14} /> {artisan.place}</p></div></div><div className="profile-story"><span className="section-kicker">THE STORY</span><p>{artisan.story}</p></div><div className="section-heading"><div><span className="section-kicker">FROM THIS MAKER</span><h3>More work by {artisan.name.split(' ')[0]}</h3></div></div><div className="product-grid">{artisanProducts.map((product) => <ProductCard key={product.id} product={product} onOpen={openProduct} />)}</div></section>;
}

export default App;

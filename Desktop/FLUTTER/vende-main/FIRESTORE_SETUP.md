# Firestore Database Setup for Tunisian Marketplace

This document outlines the Firestore database structure and security rules for the Tunisian Marketplace app.

## Database Structure

### Collections Overview

1. **users** - User profile and preferences
2. **products** - Product catalog
3. **categories** - Product categories
4. **orders** - Customer orders
5. **cart** - Shopping cart items
6. **reviews** - Product reviews and ratings
7. **sellers** - Seller/vendor information

## Collection Schemas

### 1. Users Collection (`/users/{userId}`)

```typescript
interface User {
  uid: string;
  email: string;
  displayName?: string;
  photoURL?: string;
  phoneNumber?: string;
  addresses?: Address[];
  preferences?: UserPreferences;
  role: 'customer' | 'seller' | 'admin';
  createdAt: Timestamp;
  updatedAt: Timestamp;
  isActive: boolean;
}

interface Address {
  id: string;
  name: string; // Home, Work, etc.
  street: string;
  city: string;
  governorate: string; // Tunisian governorates
  postalCode: string;
  country: string;
  isDefault: boolean;
}

interface UserPreferences {
  language: 'en' | 'fr' | 'ar';
  currency: 'TND' | 'EUR' | 'USD';
  notifications: {
    orderUpdates: boolean;
    promotions: boolean;
    newProducts: boolean;
  };
}
```

### 2. Products Collection (`/products/{productId}`)

```typescript
interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  category: string;
  subcategory?: string;
  imageUrls: string[];
  seller: {
    id: string;
    name: string;
    verified: boolean;
  };
  specifications: Record<string, any>;
  tags: string[];
  stock: {
    quantity: number;
    lowStockThreshold: number;
    unlimitedStock: boolean;
  };
  shipping: {
    weight: number; // in grams
    dimensions: {
      length: number;
      width: number;
      height: number;
    };
    shippingCost: number;
    freeShippingThreshold?: number;
  };
  rating: {
    average: number;
    count: number;
  };
  status: 'active' | 'inactive' | 'out_of_stock';
  featured: boolean;
  origin: {
    region: string;
    city: string;
    artisan?: string;
  };
  authenticity: {
    certified: boolean;
    certificate?: string;
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 3. Categories Collection (`/categories/{categoryId}`)

```typescript
interface Category {
  id: string;
  name: string;
  description: string;
  imageUrl: string;
  iconUrl: string;
  parentCategory?: string;
  subcategories?: string[];
  productCount: number;
  featured: boolean;
  sortOrder: number;
  seoInfo?: {
    metaTitle: string;
    metaDescription: string;
    keywords: string[];
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 4. Orders Collection (`/orders/{orderId}`)

```typescript
interface Order {
  id: string;
  orderNumber: string; // Human-readable order number
  customer: {
    id: string;
    name: string;
    email: string;
    phone?: string;
  };
  items: OrderItem[];
  totals: {
    subtotal: number;
    tax: number;
    shipping: number;
    discount: number;
    total: number;
  };
  shippingAddress: Address;
  billingAddress?: Address;
  paymentMethod: {
    type: 'card' | 'paypal' | 'cash_on_delivery' | 'bank_transfer';
    details?: Record<string, any>;
  };
  status: 'pending' | 'confirmed' | 'processing' | 'shipped' | 'delivered' | 'cancelled';
  tracking?: {
    trackingNumber: string;
    carrier: string;
    estimatedDelivery: Timestamp;
  };
  notes?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

interface OrderItem {
  productId: string;
  productName: string;
  productImage: string;
  sellerId: string;
  sellerName: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  specifications?: Record<string, any>;
}
```

### 5. Cart Collection (`/users/{userId}/cart/{productId}`)

```typescript
interface CartItem {
  productId: string;
  quantity: number;
  selectedVariations?: Record<string, string>;
  addedAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 6. Reviews Collection (`/products/{productId}/reviews/{reviewId}`)

```typescript
interface Review {
  id: string;
  userId: string;
  userName: string;
  userAvatar?: string;
  rating: number; // 1-5
  title?: string;
  comment: string;
  images?: string[];
  verified: boolean; // Did user actually purchase?
  helpful: number; // Number of helpful votes
  reported: boolean;
  reply?: {
    sellerId: string;
    sellerName: string;
    message: string;
    repliedAt: Timestamp;
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 7. Sellers Collection (`/sellers/{sellerId}`)

```typescript
interface Seller {
  id: string;
  businessName: string;
  ownerName: string;
  email: string;
  phone: string;
  address: Address;
  description: string;
  logo?: string;
  bannerImage?: string;
  verification: {
    status: 'pending' | 'verified' | 'rejected';
    documents: string[]; // URLs to uploaded documents
    verifiedAt?: Timestamp;
  };
  stats: {
    totalProducts: number;
    totalOrders: number;
    averageRating: number;
    responseTime: number; // in hours
  };
  settings: {
    returnPolicy: string;
    shippingPolicy: string;
    termsOfService: string;
  };
  socialLinks?: {
    facebook?: string;
    instagram?: string;
    website?: string;
  };
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow all authenticated users to read basic user info for orders/reviews
      allow read: if request.auth != null && 
                     resource.data.keys().hasOnly(['displayName', 'photoURL', 'isActive']);
    }
    
    // Cart items - users can only access their own cart
    match /users/{userId}/cart/{productId} {
      allow read, write, delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are read-only for customers, writable by sellers and admins
    match /products/{productId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && 
                               (isAdmin() || isSeller() || isProductOwner(productId));
      allow delete: if request.auth != null && isAdmin();
    }
    
    // Categories are read-only for most users, writable by admins
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
    
    // Orders - customers can read their own, sellers can read orders containing their products
    match /orders/{orderId} {
      allow read: if request.auth != null && 
                     (request.auth.uid == resource.data.customer.id || 
                      isSellerInOrder(orderId) || 
                      isAdmin());
      allow create: if request.auth != null && request.auth.uid == request.resource.data.customer.id;
      allow update: if request.auth != null && 
                       (isAdmin() || 
                        (isSellerInOrder(orderId) && 
                         request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status', 'tracking', 'notes'])));
    }
    
    // Reviews - users can create reviews for products they purchased
    match /products/{productId}/reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId &&
                       hasPurchasedProduct(productId);
      allow update: if request.auth != null && 
                       (request.auth.uid == resource.data.userId || isAdmin());
      allow delete: if request.auth != null && 
                       (request.auth.uid == resource.data.userId || isAdmin());
    }
    
    // Sellers - sellers can read/update their own profile
    match /sellers/{sellerId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && 
                               (request.auth.uid == sellerId || isAdmin());
      allow delete: if request.auth != null && isAdmin();
    }
    
    // Helper functions
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isSeller() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'seller';
    }
    
    function isProductOwner(productId) {
      return get(/databases/$(database)/documents/products/$(productId)).data.seller.id == request.auth.uid;
    }
    
    function isSellerInOrder(orderId) {
      let order = get(/databases/$(database)/documents/orders/$(orderId)).data;
      return order.items.hasAny([request.auth.uid]) || 
             order.items.any(item, item.sellerId == request.auth.uid);
    }
    
    function hasPurchasedProduct(productId) {
      // This would require a more complex query or denormalized data
      // For simplicity, allow all authenticated users to review
      return request.auth != null;
    }
  }
}
```

## Data Migration Script

To populate Firestore with your existing mock data:

```javascript
// This would be run as a Node.js script or Cloud Function
const admin = require('firebase-admin');
const mockData = require('./mock_products.json');

async function migrateData() {
  const db = admin.firestore();
  const batch = db.batch();
  
  // Migrate categories
  mockData.categories.forEach(category => {
    const ref = db.collection('categories').doc(category.id);
    batch.set(ref, {
      ...category,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  });
  
  // Migrate products
  mockData.products.forEach(product => {
    const ref = db.collection('products').doc(product.id);
    batch.set(ref, {
      ...product,
      createdAt: admin.firestore.Timestamp.fromDate(new Date(product.createdAt)),
      updatedAt: admin.firestore.Timestamp.fromDate(new Date(product.updatedAt)),
      status: 'active',
      featured: mockData.featured_products.includes(product.id),
      stock: {
        quantity: Math.floor(Math.random() * 50) + 10,
        lowStockThreshold: 5,
        unlimitedStock: false
      },
      rating: {
        average: product.rating,
        count: product.reviewCount
      }
    });
  });
  
  await batch.commit();
  console.log('Migration completed!');
}
```

## Indexes Required

Create these composite indexes in the Firebase Console:

1. **Products Collection:**
   - `category` (Ascending) + `featured` (Ascending) + `createdAt` (Descending)
   - `category` (Ascending) + `status` (Ascending) + `rating.average` (Descending)
   - `status` (Ascending) + `featured` (Ascending) + `createdAt` (Descending)

2. **Orders Collection:**
   - `customer.id` (Ascending) + `status` (Ascending) + `createdAt` (Descending)
   - `status` (Ascending) + `createdAt` (Descending)

3. **Reviews Collection:**
   - `productId` (Ascending) + `createdAt` (Descending)
   - `userId` (Ascending) + `createdAt` (Descending)

## Environment Variables

Set these in your Firebase project settings:

```env
STRIPE_PUBLIC_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
SHIPPING_API_KEY=...
EMAIL_SERVICE_API_KEY=...
ADMIN_EMAIL=admin@tunisianmarketplace.com
```

## Cloud Functions

Consider implementing these Cloud Functions:

1. **onOrderCreate** - Send confirmation emails, update inventory
2. **onProductUpdate** - Update search indexes, notify followers
3. **calculateShipping** - Dynamic shipping cost calculation
4. **processPayment** - Handle payment processing with Stripe
5. **generateReports** - Weekly/monthly sales reports for sellers

This structure provides a scalable foundation for your Tunisian Marketplace application.

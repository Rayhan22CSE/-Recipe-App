/**
 * One-Time Admin Cloud Firestore Recipe Seeder
 * Target Project: recipe-app-39d4f
 * 
 * Usage:
 *   1. Supply service account key:
 *      Save your Firebase private key as `scripts/service-account.json`
 *      OR set GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json
 * 
 *   2. Run command:
 *      node scripts/seed_firestore.js
 */

const fs = require('fs');
const path = require('path');
const { initializeApp, cert, applicationDefault, getApps } = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');

const PROJECT_ID = 'recipe-app-39d4f';
const DATASET_PATH = path.join(__dirname, '..', 'assets', 'sample_recipes_dataset.json');
const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || path.join(__dirname, 'service-account.json');

function initFirestore() {
  if (!getApps().length) {
    if (fs.existsSync(serviceAccountPath)) {
      console.log(`🔑 Using Service Account Key from: ${serviceAccountPath}`);
      const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
      initializeApp({
        credential: cert(serviceAccount),
        projectId: PROJECT_ID,
      });
    } else {
      console.log(`🔑 Using Application Default Credentials (ADC) for project: ${PROJECT_ID}...`);
      initializeApp({
        credential: applicationDefault(),
        projectId: PROJECT_ID,
      });
    }
  }
  return getFirestore();
}

async function seedFirestore() {
  console.log(`\n==================================================`);
  console.log(`🔥 Starting One-Time Firestore Recipe Seeder`);
  console.log(`🎯 Target Project ID: ${PROJECT_ID}`);
  console.log(`==================================================\n`);

  try {
    const db = initFirestore();
    const recipesRef = db.collection('recipes');

    // Step 1: Check existing documents in recipes collection
    console.log('🔍 Checking if recipes collection already contains documents...');
    const snapshot = await recipesRef.limit(1).get();

    if (!snapshot.empty) {
      console.log(`\n⚠️  Recipes already exist in Firestore collection (${snapshot.size} document found).`);
      console.log(`🛑 Stopping seeder to prevent overwriting existing data.`);
      return;
    }

    // Step 2: Read dataset JSON file
    if (!fs.existsSync(DATASET_PATH)) {
      throw new Error(`Dataset file not found at: ${DATASET_PATH}`);
    }

    const rawData = fs.readFileSync(DATASET_PATH, 'utf8');
    const recipes = JSON.parse(rawData);
    console.log(`\n📖 Loaded ${recipes.length} sample recipes from assets/sample_recipes_dataset.json.`);

    // Step 3: Batch Write Recipes to Firestore
    const batch = db.batch();
    let count = 0;

    for (const recipe of recipes) {
      const docRef = recipesRef.doc(); // Auto-generate document ID
      const title = recipe.name || recipe.title || 'Untitled Recipe';
      const createdAtDate = recipe.createdAt ? new Date(recipe.createdAt) : new Date();

      const docData = {
        name: title,
        title: title,
        description: recipe.description || '',
        imageUrl: recipe.imageUrl || '',
        category: recipe.category || 'General',
        calories: recipe.calories || 0,
        preparationTime: recipe.preparationTime || 20,
        cookingTime: recipe.preparationTime || 20,
        rating: recipe.rating || 4.5,
        reviewCount: recipe.reviewCount || 10,
        servings: recipe.servings || 2,
        createdBy: recipe.createdBy || 'Chef',
        createdAt: Timestamp.fromDate(createdAtDate),
        ingredients: recipe.ingredients || [],
        instructions: recipe.instructions || [],
      };

      batch.set(docRef, docData);
      count++;
      console.log(`📝 [${count}/${recipes.length}] Prepared "${title}" (Doc ID: ${docRef.id})`);
    }

    console.log(`\n🚀 Committing batch write to Cloud Firestore...`);
    await batch.commit();

    console.log(`\n==================================================`);
    console.log(`🎉 Seeding Complete! Successfully inserted ${count} recipes into Firestore.`);
    console.log(`==================================================\n`);
  } catch (error) {
    console.error(`\n❌ Error during Firestore seeding:`, error.message);
    if (error.message.includes('Could not load the default credentials')) {
      console.log(`\n💡 How to execute the seeder:`);
      console.log(`   1. Go to Firebase Console -> Project Settings -> Service Accounts.`);
      console.log(`   2. Click "Generate new private key" and save as "scripts/service-account.json".`);
      console.log(`   3. Run: node scripts/seed_firestore.js\n`);
    }
    process.exit(1);
  }
}

seedFirestore();

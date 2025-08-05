const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onCall, onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { algoliasearch } = require("algoliasearch");

admin.initializeApp();
const db = admin.firestore();

// Dati da Algolia
const ALGOLIA_APP_ID = "SJDXTBVPB7";
const ALGOLIA_ADMIN_KEY = "f744dd1f0644e4c34a46ac695a333b1e";
const ALGOLIA_INDEX_NAME = "canzoni";

const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

exports.searchCanzoni = onCall(async (request) => {
  const query = request.data.query || "";

  try {
    const results = await client.searchSingleIndex({
      indexName: ALGOLIA_INDEX_NAME,
      searchParams: {
        query,
        hitsPerPage: 10,
        attributesToHighlight: ['titolo', 'artista'],
        typoTolerance: true,
        highlightPreTag: '<mark>',
        highlightPostTag: '</mark>',
      },
    });

    return results.hits.map((hit) => ({
      titolo: hit.titolo,
      artista: hit.artista,
      album: hit.album,
      objectID: hit.objectID,
      highlight: hit._highlightResult,
    }));
  } catch (error) {
    console.error("Errore durante la ricerca Algolia:", error);
    throw new Error("Errore nella ricerca.");
  }
});

// const index = client.getIndex(ALGOLIA_INDEX_NAME);

/**
 * Trigger quando viene creato un documento Firestore
 * (es: /songs/{songId})
 */
exports.onSongCreated = onDocumentCreated("canzoni/{cid}", async (event) => {
  const data = event.data.data();
  const objectID = event.params.cid;

  await results.saveObject({
    objectID,
    ...data,
  });
});

/**
 * Trigger quando viene modificato
 */
exports.onSongUpdated = onDocumentUpdated("canzoni/{cid}", async (event) => {
  const newData = event.data.after.data();
  const objectID = event.params.cid;

  await index.saveObject({
    objectID,
    ...newData,
  });
});

/**
 * Trigger quando viene eliminato
 */
exports.onSongDeleted = onDocumentDeleted("canzoni/{cid}", async (event) => {
  const objectID = event.params.cid;

  await results.deleteObject(objectID);
});

exports.syncAllSongsToAlgolia = onRequest(async (req, res) => {
  try {
    const snapshot = await db.collection("canzoni").get();

    const objects = snapshot.docs.map((doc) => ({
      objectID: doc.id,
      ...doc.data(),
    }));

    await results.saveObjects(objects);

    res.status(200).send("Sincronizzazione iniziale completata.");
  } catch (error) {
    console.error("Errore nella sincronizzazione:", error);
    res.status(500).send("Errore nella sincronizzazione.");
  }
});
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { algoliasearch } = require("algoliasearch");

admin.initializeApp();

// Dati da Algolia
const ALGOLIA_APP_ID = "SJDXTBVPB7";
const ALGOLIA_ADMIN_KEY = "f744dd1f0644e4c34a46ac695a333b1e";
const ALGOLIA_INDEX_NAME = "canzoni";

const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

exports.searchCanzoni = functions.https.onCall(async (data, context) => {
  const query = data.query || "";

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
      highlight: hit._highlightResult, // opzionale per mostrare evidenziazioni
    }));
  } catch (error) {
    console.error("Errore durante la ricerca Algolia:", error);
    throw new functions.https.HttpsError("internal", "Errore nella ricerca.");
  }
});


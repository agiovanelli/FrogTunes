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
        attributesToHighlight: ['title', 'artista'],
        typoTolerance: true,
        highlightPreTag: '<mark>',
        highlightPostTag: '</mark>',
      },
    });

    return results.hits.map((hit) => ({
      title: hit.title,
      artista: hit.artista,
      album: hit.album,
      cover: hit.cover,
      objectID: hit.objectID,
      highlight: hit._highlightResult,
    }));
  } catch (error) {
    console.error("Errore durante la ricerca Algolia:", error);
    throw new Error("Errore nella ricerca.");
  }
});

// Funzione per indicizzare un oggetto
async function saveToAlgolia(data, objectID) {
  try{
    const artistIds = data.artistId || [];
    let artistNames = [];

    if(artistIds.length > 0){
      const artistSnapshot = await db
      .collection('artisti')
      .where(admin.firestore.FieldPath.documentId(), 'in', artistIds)
      .get();

      artistNames = artistSnapshot.docs.map(doc => doc.data().nome);
    }

    const record = {
      objectID,
      ...data,
      // artistIds,
      artista: artistNames,
    };

    await client.saveObjects({
      indexName: ALGOLIA_INDEX_NAME,
      objects: [{ objectID, ...record }],
    });

    console.log(`Canzone ${objectID} indicizzata con successo.`);
  } catch (error) {
    console.error("Errore in saveToAlgolia:", error);
  }
}

// Funzione per rimuovere da Algolia
async function deleteFromAlgolia(objectID) {
  await client.deleteObjects({
    indexName: ALGOLIA_INDEX_NAME,
    objectIDs: [objectID],
  });
}

// CREAZIONE documento Firestore → indicizza su Algolia
exports.onSongCreated = onDocumentCreated("canzoni/{cid}", async (event) => {
  const data = event.data.data();
  const objectID = event.params.cid;

  await saveToAlgolia(data, objectID);
});

// AGGIORNAMENTO documento Firestore → aggiorna su Algolia
exports.onSongUpdated = onDocumentUpdated("canzoni/{cid}", async (event) => {
  const newData = event.data.after.data();
  const objectID = event.params.cid;

  await saveToAlgolia(newData, objectID);
});

// ELIMINAZIONE documento Firestore → rimuove da Algolia
exports.onSongDeleted = onDocumentDeleted("canzoni/{cid}", async (event) => {
  const objectID = event.params.cid;

  await deleteFromAlgolia(objectID);
});

exports.syncAllSongsToAlgolia = onRequest(async (req, res) => {
  try {
    const snapshot = await db.collection("canzoni").get();

    if (snapshot.empty) {
      console.warn("La collezione 'canzoni' è vuota.");
      return res.status(200).send("Nessun documento da sincronizzare.");
    }

    let objects = [];

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const objectID = doc.id;

      const artistIds = data.artistId || [];
      let artistNames = [];

      if (artistIds.length > 0) {
        const artistSnapshots = await db
          .collection("artisti")
          .where(admin.firestore.FieldPath.documentId(), "in", artistIds)
          .get();

        artistNames = artistSnapshots.docs.map((artistDoc) => artistDoc.data().nome);
      }

      objects.push({
        objectID,
        ...data,
        // artistIds,
        artista: artistNames, // array di nomi leggibili
      });
    }

    console.log("Sto sincronizzando i seguenti oggetti su Algolia:", objects);

    await client.saveObjects({
      indexName: ALGOLIA_INDEX_NAME,
      objects,
    });

    res.status(200).send("Sincronizzazione completata con successo.");
  } catch (error) {
    console.error("Errore nella sincronizzazione:", error.message, error);
    res.status(500).send("Errore nella sincronizzazione: " + error.message);
  }
});

exports.onNewStream = onDocumentCreated("eventiAscolto/{eventId}", async (event) => {
  const data = event.data.data();
  if (!data || !data.songId || !data.paese) {
    console.error("Dati evento ascolto mancanti o incompleti:", data);
    return;
  }

  const songRef = db.collection("canzoni").doc(data.songId);

  try {
    await songRef.update({
      ascoltiTotali: admin.firestore.FieldValue.increment(1),
      [`statPaese.${data.paese}`]: admin.firestore.FieldValue.increment(1),
    });

    console.log(`Aggiornati ascolti per canzone ${data.songId} da paese ${data.paese}`);
  } catch (error) {
    console.error("Errore durante l'aggiornamento degli ascolti:", error);
  }
});

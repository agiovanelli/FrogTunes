# Introduzione 
In questo documento sono descritti l'ambito, l'approccio e il programma delle attività di testing che si ha intenzione di svolgere lungo tutta la fase finale del progetto. Ho scelto di attendere che l'applicazione fosse sviluppata almeno in parte; essendo infatti un progetto di piccole dimensioni risultava pressoche' inutile eseguire test nelle prime fasi, come è invece usuale fare secondo le linee guida di standard sul testing (come IEEE 928).

Lo scopo principale di queste attività di testing è quello di verificare e validare il codice secondo i requisiti già classificati nella specifica dei requisiti. Viene inoltre testato il codice per identificare eventuali errori, bug e failure.
Per differenziare i risultati e quindi scoprire più difetti, è stata scelta una tecnica mista di testing che comprende principalmente quella manuale basata sui parametri sopra specificati.

# Funzionalità oggetto dei test
Il software, oltre alla divisione per attore, quindi Utente, Artista, Manager ed Etichetta, presenta anche una sezione per gestire il database Firebase e per gestire la riproduzione musicale e tutti i comandi relativi.
Le attività di testing verranno eseguite separatamente su queste tutte queste sezioni ogni volta che una funzionalità viene aggiunta, in quanto devono funzionare in modo sincrono, e in fase finale sul software completo.

# Test
- Test-1:
  - Data: 06/02/2025
  - Argomento: login
  - Obiettivo: controllare se il meccanismo di login funzioni correttamente comunicando col database
  - Cosa mi aspetto dal test: buona riuscita
  - Risultato del test: positivo
- Test-2:
  - Data: 28/05/2025
  - Argomento: comunicazione con database lato utente (solo Firestore)
  - Obiettivo: controllare se il meccanismo di login e registrazione funzioni correttamente comunicando col database
  - Cosa mi aspetto dal test: buona riuscita o possibili errori derivanti dalle versioni
  - Risultato del test: positivo
- Test-3:
  - Data: 22/07/2025
  - Argomento: comunicazione con database (Firestore e Storage)
  - Obiettivo: controllare se il corretto funzionamento del bucket del database per la corretta comunicazione con l'applicazione
  - Cosa mi aspetto dal test: buona riuscita
  - Risultato del test: positivo
- Test-4:
  - Data: 23/07/2025
  - Argomento: comunicazione con database lato artista, manager ed etichetta (solo Firestore)
  - Obiettivo: controllare se il meccanismo di login e registrazione funzioni correttamente comunicando col database
  - Cosa mi aspetto dal test: buona riuscita
  - Risultato del test: positivo
- Test-5:
  - Data: 06/08/2025
  - Argomento: comunicazione con Algolia
  - Obiettivo: controllare se la funzione di ricerca che tramite Firebase comunica con Algolia funzioni
  - Cosa mi aspetto dal test: buona riuscita o problemi con le versioni riguardo funzioni JavaScript di Firebase
  - Risultato del test: positivo
- Test-6:
  - Data: 19/09/2025
  - Argomento: funzionamento sezione Playlist
  - Obiettivo: controllare se la sezione Playlist funzioni e comunichi correttamente con il database e le interfacce già presenti
  - Cosa mi aspetto dal test: buona riuscita o interferenze dovuto al sincronismo
  - Risultato del test: non completamente positivo
- Test-7:
  - Data: 23/09/2025
  - Argomento: riproduzione musicale
  - Obiettivo: controllare che la riproduzione musicale funzioni correttamente e che non vada in conflitto con le componenti già presenti
  - Cosa mi aspetto dal test: buona riuscita o interferenze "Future"
  - Risultato del test: positivo
- Test-8:
  - Data: 01/10/2025
  - Argomento: coda, playlist e riproduzione musicale
  - Obiettivo: controllare che la riproduzione musicale non vada in conflitto con le playlist e che la coda funzioni correttamente
  - Cosa mi aspetto dal test: buona riuscita
  - Risultato del test: positivo
- Test-9:
  - Data: 06/10/2025
  - Argomento: sezione utente
  - Obiettivo: controllo generale della sezione utente circa il corretto funzionamento di tutte le sue parti
  - Cosa mi aspetto dal test: buona riuscita o conflitti tra diversi widget
  - Risultato del test: positivo
- Test-10:
  - Data: 11/10/2025
  - Argomento: caricamento brani singoli
  - Obiettivo: controllo relativo al corretto caricamento di brani singoli
  - Cosa mi aspetto dal test: buona riuscita o conflitti con comunicazione col database
  - Risultato del test: positivo
- Test-11:
  - Data: 13/10/2025
  - Argomento: sezione artista
  - Obiettivo: controllo generale della sezione artista circa il corretto funzionamento di tutte le sue parti
  - Cosa mi aspetto dal test: buona riuscita o conflitti tra diversi widget
  - Risultato del test: positivo
- Test-12:
  - Data: 14/10/2025
  - Argomento: sezione manager
  - Obiettivo: controllo generale della sezione manager circa il corretto funzionamento di tutte le sue parti
  - Cosa mi aspetto dal test: buona riuscita o conflitti tra diversi widget
  - Risultato del test: positivo
- Test-13:
  - Data: 15/10/2025
  - Argomento: sezione etichetta
  - Obiettivo: controllo generale della sezione etichetta circa il corretto funzionamento di tutte le sue parti
  - Cosa mi aspetto dal test: buona riuscita o conflitti tra diversi widget
  - Risultato del test: positivo
- Test-14:
  - Data: 18/10/2025
  - Argomento: caricamento video musicale e testo canzone
  - Obiettivo: controllo corretta visualizzazione video musicale e testo della canzone
  - Cosa mi aspetto dal test: buona riuscita o conflitti con database
  - Risultato del test: positivo
- Test-15:
  - Data: 20/10/2025
  - Argomento: UI
  - Obiettivo: controllo generale dell'UI dell'applicazione 
  - Cosa mi aspetto dal test: buona riuscita
  - Risultato del test: positivo

## Introduzione

Robusto e completo catalogo musicale digitale, destinato a soddisfare le esigenze e le aspettative di una vasta gamma di utenti, artisti, manager ed etichette discografiche.

FrogTunes sarà quindi una piattaforma digitale avanzata dove potremo trovare tutti i contenuti di un artista musicale (es: recensioni dei brani/album, podcast e live studio session da parte degli artisti etc …).
Sarà inoltre dotato di diverse funzionalità rivolte a tutti gli utenti della piattaforma: gli utenti finali infatti potranno cercare, ascoltare, gestire e condividere la loro musica preferita. Gli artisti avranno la possibilità di gestire il loro catalogo musicale, inclusi i dettagli delle canzoni e i video musicali associati. I manager degli artisti avranno strumenti per la gestione dei loro talenti e delle informazioni associate. Le etichette discografiche avranno il controllo e la visibilità su tutte le attività all'interno della piattaforma.

In questa specifica dei requisiti adotteremo le seguenti notazioni:
* (_testo_) descrizione della funzionalità/componente 
* [_testo_] eventuali casi di errore o eccezioni
* {_testo_} priorità dei requisiti secondo la classificazione MOSCOW


## Descrizione Generale

Di seguito sono elencate la varie funzionalità della piattaforma **FrogTunes** e le diverse casistiche di errore/variabilità.

### Funzionalità del catalogo musicale
#### Chiunque
* Accesso alla applicazione (con i diversi casi iniziali) {Must}

#### Utente
* Creazione delle credenziali personali {Must}
* Scelta del piano di abbonamento {Could}
* Ricerca file multimediale o artista musicale [canzone/artista non esiste] {Must}
* Selezione del file multimediale da riprodurre, in caso di raccolta di file vi è possibilità di riprodurre casualmente i file oppure selezionare manualmente (se album, può selezionare l’ascolto casuale altrimenti parte dalla prima canzone) {Must}
* Mettere in pausa la riproduzione {Must}
* Fare ricominciare il file da capo {Must}
* Creazione, eliminazione, modifica e condivisione di playlist {Should}
* Aggiunta ed eliminazione di file all’interno di una playlist selezionata [utente elimina tutti i brani, la playlist esiste ancora?] {Should}
* Selezione e visione del video relativo al file selezionato, se presente {Should}
* Mettere in coda i file multimediali {Should}
* Recensione del file e/o del relativo video, commento con limitazione di numero di caratteri [utente scrive un commento non concesso] {Should}
* Aggiunge valutazione alla recensione {Could}
* Guarda live artista {Won't}
* Riproduzione offline del file e/o del relativo video, funzionalità concessa solo per uno specifico abbonamento {Won't}

#### Artista
* Upload del / dei file multimediali, inserimento delle relative informazioni (opzionale) {Must}
* Upload del video, se file multimediale già presente {Must}
* Riproduzione dei propri file multimediali caricati in precedenza (visto come utente) {Must}
* Risposta a recensioni relative a canzoni di sua proprietà [artista scrive una risposta non concessa] {Must}
* Modifica delle informazioni relative al file multimediale {Should}
* Trasmissione in diretta, selezione di artisti che possono farlo [improvvisa disconnessione da internet] (non tutti gli artisti possono farlo) {Won't}

#### Manager
* Aggiunta degli artisti che gestisce in un’area dedicata {Must}
* Modifica di informazioni relative ai file degli artisti che gestisce {Must}
* Aggiunta dei testi delle canzoni dei propri artisti [Manager e artista aggiungono lo stesso contenuto] {Should}

#### Etichetta
* Gestisce i propri manager e i relativi artisti (ne decide il tipo) {Must}
* Elimina e crea i profili degli artisti gestiti dal manager {Could}
* Analizza i dati relativi alle riproduzioni dei suoi artisti {Must} 
* Riceve pagamento dalla piattaforma in base agli ascolti dei suoi artisti (varia dalla grandezza dell’etichetta, e quindi dal numero di views di ogni suo artista) {Should} 
* Decide specifiche di upload di ogni artista (quanti brani/video caricare) in base alle views (lo stato di un’artista è variabile) {Won't}

### Piani abbonamento utente {Could}
1. Gratuito (0 euro / mese) = ascolto gratuito della musica selezionando playlist e album ma con riproduzione casuale e ascolto solo online con pubblicità

2. Base (Y euro / mese) = ascolto illimitato con possibilità di creare playlist e scaricare musica

3. Premium (Z euro / mese) = accesso a contenuti extra per una full experience, video, live session, interviste, podcast

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
* Utente sceglie il suo piano di abbonamento e crea le proprie credenziali {Must}
* Utente cerca canzone/artista [canzone/artista non esiste] {Must}
* Utente seleziona brano/album da ascoltare  {Must}
(se album, può selezionare l’ascolto casuale altrimenti parte dalla prima canzone)
* Utente decide se guardare il video musicale {Should}
(supponendo che ci sia)
* Utente mette in pausa {Must}
* Utente fa ripartire la canzone {Must}
(anche il video se c’è)
* Utente mette in coda canzoni {Must}
* Utente crea, modifica, condivide playlist {Should}
* Utente aggiunge ed elimina brani da playlist selezionata [utente elimina tutti i brani, la playlist esiste ancora?] {Should}
* Utente scarica musica e/o video musicale [il dispositivo non ha più spazio di archiviazione]
(a seconda del tipo di abbonamento che dispone) {Could}
* Utente recensisce un brano o video [utente scrive un commento non concesso]
(valutazione obbligatoria e commento opzionale con max caratteri) {Could}

#### Artista
* Artista carica brano, inserisce le varie informazioni base della canzone e carica video musicale del brano {Must}
(opzionale)
* Artista può ascoltare solo la propria musica. Se vuole ascoltare altri artisti deve fare un abbonamento {Must}
(visto come utente)
* Artista può rispondere ad una recensione di un utente [artista scrive una risposta non concessa] {Must}
* Artista può trasmettere live [improvvisa disconnessione da internet] {Could}
(non tutti gli artisti possono farlo)

#### Manager
* Manager aggiunge i suoi artisti {Must}
* Manager può modificare roaster artisti, informazioni dei brani degli artisti {Must}
* Manager aggiunge testi canzoni artisti [Manager e artista aggiungono lo stesso contenuto] {Should}

#### Etichetta
* Etichetta discografica gestisce manager {Must}
(ne decide il tipo)
* Può eliminare o creare i profili degli artisti gestiti dal manager {Must}
* Etichetta riceve un pagamento dalla piattaforma in base agli ascolti {Won't}
(varia dalla grandezza dell’etichetta, e quindi dal numero di views di ogni suo artista) 
* Etichetta decide specifiche di upload di ogni artista (quanti brani/video caricare) in base alle views (lo stato di un’artista è variabile) {Could}

### Piani abbonamento utente {Must}
1. Abbonamento gratuito (0 euro) = ascolto gratuito della musica selezionando playlist e album ma con riproduzione casuale e ascolto solo online con pubblicità

2. Abbonamento base (Y euro) = ascolto illimitato con possibilità di creare playlist e scaricare musica

3. Abbonamento avanzato (Z euro) = accesso a contenuti extra per una full experience, video, live session, interviste, podcast

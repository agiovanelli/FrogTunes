#Architettura con Stile di Programma Principale e Subroutine per FrogTunes.
* **Programma Principale**
           -Descrizione: Il programma principale gestisce il flusso generale dell'applicazione FrogTunes e coordina l'esecuzione delle subroutine specializzate per fornire le varie funzionalità della piattaforma.
	   -Implementazione: Il programma principale avvia l'applicazione, gestisce l'autenticazione degli utenti, e dirige le richieste agli specifici moduli di subroutine.
* **Subroutine Principali**:
	* *Gestione Utenti:*
	   -Descrizione: Subroutine responsabile della registrazione, autenticazione e gestione delle informazioni degli utenti.
	   -Implementazione: Fornisce funzioni per la registrazione, il login, e la gestione del profilo utente.
	* *Gestione Artisti:*
	   -Descrizione: Subroutine dedicata alla gestione degli artisti, consentendo loro di caricare e gestire il proprio catalogo musicale.
	   -Implementazione: Fornisce funzioni per l'upload di brani, la gestione del catalogo artistico e la risposta alle recensioni.
	* *Gestione Playlist:*
	   -Descrizione: Subroutine per la creazione, modifica e condivisione di playlist da parte degli utenti.
	   -Implementazione: Fornisce funzioni per la creazione, la modifica e la condivisione di playlist.
	* *Gestione Recensioni:*
	   -Descrizione: Subroutine per la gestione delle recensioni degli utenti su brani e album.
	   -Implementazione: Fornisce funzioni per l'invio, la visualizzazione e la risposta alle recensioni.
	* *Servizi di Ricerca e Ascolto:*
	   -Descrizione: Subroutine responsabile della ricerca e riproduzione di brani musicali.
	   -Implementazione: Fornisce funzioni per la ricerca di brani, la riproduzione, la messa in pausa, l'avanzamento e la gestione della coda.
	* *Gestione Manager e Etichette:*
	   -Descrizione: Subroutine dedicata alla gestione di manager e etichette discografiche.
	   -Implementazione: Fornisce funzioni per l'aggiunta e la modifica di manager, la gestione di roster artisti e la visualizzazione delle attività.

* **Flusso di Esecuzione:**
	* *Avvio dell'Applicazione:*
	Il programma principale avvia l'applicazione FrogTunes.
	* *Autenticazione Utente:*
	Gli utenti si autenticano attraverso il programma principale.
	* *Direzione alle Subroutine:*
	In base alle azioni degli utenti, il programma principale dirige le richieste alle subroutine corrispondenti.
	* *Esecuzione delle Subroutine:*
	Le subroutine eseguono operazioni specifiche come la gestione degli utenti, la gestione degli artisti, la ricerca e riproduzione di brani, ecc.
	* *Coordinamento e Risposta:*
	Il programma principale coordina l'esecuzione delle subroutine e gestisce le risposte ritornate.


	* *Ciclo di Vita:*
	Le subroutine vengono chiamate e chiuse in modo dinamico in base alle richieste degli utenti.
	* *Interfaccia Utente:*
	L'interfaccia utente interagisce principalmente con il programma principale, che a sua volta comunica con le subroutine.


 
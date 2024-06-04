# Introduzione 
In questo progetto per il corso di ingegneria del software, il nostro obiettivo è la progettazione e lo sviluppo di un robusto e completo catalogo musicale digitale (FrogTunes), destinato a soddisfare le esigenze e le aspettative di una vasta gamma di utenti, artisti, manager ed etichette discografiche.
Il team che svilupperà il progetto è composto da: Alessio Giovanelli, Biagio Testa, Fabio Izzo e Marco Zanda.

# Modello di processo
Come modello per il ciclo di vita del progetto abbiamo scelto la struttura seguente:
* Analisi del problema (individuazione dell' target e individuazione del UoD)
* Elicitazione dei requisiti 
* Ingegneria dei requisiti (con relativa produzione di una specifica dei requisiti)
* Modellazione
* Progettazione e implementazione in sincrono delle due macro sezioni del progetto (front-end e back-end)
* Produzione del codice di sistema 
* Modellazione di complessità e documentazione del codice 
* Testing e manutenzione

# Organizzazione del progetto 
Di seguito è specificata una macro-divisione delle fasi del progetto tra i componenti del team:

* **Stesura traccia** _[Tutti]_

* **Fase preliminare**  _[Marco Zanda e Fabio Izzo]_
    - Organizzazione del team 
    - Organizzazione della documentazione 
    - Organizzazione del lavoro 

* **Elicitazione dei requisiti** _[Tutti]_

    Analisi basata sullo scenario

* **Ingegneria dei requisiti** _[Marco Zanda e Fabio Izzo]_

    Creazione specifica dei requisiti 


* **Modellazione** _[Alessio Giovanelli e Biagio Testa]_
    - Schema ER	
    - Macchine a stati finiti
    - Diagrammi UML 

* **Sviluppo**

	- front end   _[Alessio Giovanelli e Biagio Testa]_
	- back end    _[Alessio Giovanelli e Biagio Testa]_
	- database    _[Marco Zanda e Fabio Izzo]_
	- prototipazione	    _[Alessio Giovanelli e Biagio Testa]_
	- documentazione codice   _[Marco Zanda e Fabio Izzo]_

* **Manutenzione futura** _[Tutti]_

Considerando il team stesso come potenziale utente del sistema è chiaro che il rapporto tra il progetto e l'utente è senza soluzione di continuità.

# Standard, linee guida, procedure e attività di gestione 
I dettagli del problema affrontato in questo progetto non sono già specificati, ma è comunque ben definita una struttura dell'applicazione (suddivisa) e l'obbiettivo finale da raggiungere. 

Questo ci ha portato a indirizzarci verso un *meccanismo di coordinamento divisionale* (Mintzberg), che ci permetta di contribuire singolarmente alle varie porzioni del progetto, sviluppando ogni divisione e gestendo progressivamente le specifiche.

Il fatto che i dettagli non siano ben delineati ci porta però a non seguire in modo letterale il meccanismo (che richiede una specifica del risultato finale molto precisa), ma a confrontarci durante tutte le fasi del progetto per decidere in modo unanime cosa è preferibile sviluppare.

È quindi chiaro che non ci sarà una vera e propria struttura gerarchica all'interno del gruppo, ma le responsabilità decisionali e di coordinamento saranno amministrate da tutti i componenti del gruppo.

La gestione dell'intero team è dettata da obbiettivi già prefissati dai coordinatori del corso. Il rispetto di tale obbiettivi sarà verificato tramite la pubblicazione di commit sulla piattaforma GitHub che il team usa per la gestione del progetto.

# Rischi
La potenziale grandezza e complessità del progetto ci pone dei rischi sull'effettivo sviluppo dell'applicazione e sulla gestione complessiva del progetto. Parte di questi rischi sono affrontati nella specifica dei requisiti, ciò non toglie la possibilità che alcuni requisiti non vengano soddisfatti nei tempi prestabiliti.
Potenziali rischi di supporto hardware dell'applicazione sono da considerare presso che inesistenti.

# Metodi e tecniche
Per la coordinazione del progetto è stato scelto l'uso di GitHub tramite una cartella privata (https://github.com/agiovanelli/progettoIngegneriaDelSW23_24) condivisa tra i membri del team. 
Per lo sviluppo di diagrammi, documentazione e specifiche abbiamo seguito le indicazioni date a lezione e gli standard consigliati nel libro di testo (i diagrammi sono stati infatti sviluppati seguendo lo standard UML). La stesura della documentazione è stata eseguita su editor di testo forniti da Windows e IOS e l'editor di diagrammi online Draw.IO.
Abbiamo scelto di sviluppare l'applicazione utilizzando il linguaggio Java (in particolare utilizzando il plugin Java WindowBuilder per la gestione della grafica, e altre librerie base di Java), supportato dall'IDE Eclipse.

# WorkPackage 
si rimanda alla sezione _Organizzazione del progetto_

# Risorse e Budjet
Oltre alle risorse personali ci siamo avvalsi dell'utilizzo dei nostri PC personali e universitari. 
Non è previsto un Budget per questo progetto 

# Cambiamenti
Per l'attività di testing seguiremo lo standard IEEE 982 sviluppando un piano di testo contenente: test design specificazion, specifica del scenario di testo e test procedure specification.
Si occuperanno della stesura del documento Marco Zanda e Fabio Izzo mentre per l'esecuzione materiale dei test manuali sarà coinvolto tutto il team.

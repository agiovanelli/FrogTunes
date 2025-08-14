class Coda {
  // Lista delle canzoni in coda
  static final List<Map<String, dynamic>> _coda = [];

  // Aggiunge una canzone alla coda
  static void aggiungi(Map<String, dynamic> song) {
    _coda.add(song);
  }

  // Rimuove una canzone dalla coda
  static void rimuovi(int index) {
    if (index >= 0 && index < _coda.length) {
      _coda.removeAt(index);
    }
  }

  // Svuota la coda
  static void cancellaCoda() {
    _coda.clear();
  }

  static List<Map<String, dynamic>> getCoda() {
    return List.unmodifiable(_coda);
  }
}
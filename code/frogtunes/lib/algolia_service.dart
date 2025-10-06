import 'package:algolia/algolia.dart';

// Design pattern singleton per Algolia
class AlgoliaService {
  static const Algolia _algolia = Algolia.init(
    applicationId: 'SJDXTBVPB7',
    apiKey: '5c78a6db483860aac49fcc2eb52e8279',
  );
 
  static Algolia get instance => _algolia;
}

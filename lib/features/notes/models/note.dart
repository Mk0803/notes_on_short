import 'package:isar/isar.dart';

part 'note.g.dart';

@Collection()
class Note {
  Id id = Isar.autoIncrement;
  late String title;
  String? content;
  late String noteColor;
  bool isStarred = false;
  late DateTime created;
  late DateTime lastModified;
  bool isSynced = false;
}

import 'package:isar/isar.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:isar_flutter_libs/isar_flutter_libs.dart';

part 'chapter.g.dart';

@collection
@Name("Chapter")
class Chapter {
  Id? id;

  int? mangaId;

  String? name;

  String? url;

  String? dateUpload;

  String? scanlator;

  bool? isBookmarked;

  bool? isRead;

  String? lastPageRead;

  ///Only for local archive Comic
  String? archivePath;

  final manga = IsarLink<Manga>();

  Chapter(
      {this.id = Isar.autoIncrement,
      required this.mangaId,
      required this.name,
      this.url = '',
      this.dateUpload = '',
      this.isBookmarked = false,
      this.scanlator = '',
      this.isRead = false,
      this.lastPageRead = '',
      this.archivePath = ''});

  Chapter.fromJson(Map<String, dynamic> json) {
    archivePath = json['archivePath'];
    dateUpload = json['dateUpload'];
    id = json['id'];
    isBookmarked = json['isBookmarked'];
    isRead = json['isRead'];
    lastPageRead = json['lastPageRead'];
    mangaId = json['mangaId'];
    name = json['name'];
    scanlator = json['scanlator'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() => {
        'archivePath': archivePath,
        'dateUpload': dateUpload,
        'id': id,
        'isBookmarked': isBookmarked,
        'isRead': isRead,
        'lastPageRead': lastPageRead,
        'mangaId': mangaId,
        'name': name,
        'scanlator': scanlator,
        'url': url
      };

  Future<void> update() async {
    final isar = Isar.getInstance();
    if (isar != null) {
      await isar.writeTxn(() async {
        await isar.chapters.put(this);
      });
    }
  }
}

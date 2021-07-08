import 'dart:ui';

import 'package:app/models/album.dart';
import 'package:app/models/song.dart';
import 'package:app/providers/song_provider.dart';
import 'package:app/ui/widgets/app_bar.dart';
import 'package:app/ui/widgets/bottom_space.dart';
import 'package:app/ui/widgets/song_list.dart';
import 'package:app/ui/widgets/song_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide AppBar;
import 'package:provider/provider.dart';

enum OrderBy {
  TrackNumber,
  SongTitle,
  RecentlyAdded,
}

Map<OrderBy, String> _sortOptions = {
  OrderBy.TrackNumber: 'Track number',
  OrderBy.SongTitle: 'Song title',
  OrderBy.RecentlyAdded: 'Recently added',
};

OrderBy _currentSortOrder = OrderBy.TrackNumber;

class AlbumDetailsScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailsScreen({Key? key, required this.album}) : super(key: key);

  _AlbumDetailsScreenState createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  late List<Song> songs;
  late SongProvider songProvider;
  late OrderBy _sortOrder;

  @override
  void initState() {
    super.initState();

    songProvider = context.read();
    songs = songProvider.byAlbum(widget.album);
    setState(() => _sortOrder = _currentSortOrder);
  }

  List<Song> sortSongs({required OrderBy orderBy}) {
    switch (orderBy) {
      case OrderBy.SongTitle:
        return songs..sort((a, b) => a.title.compareTo(b.title));
      case OrderBy.TrackNumber:
        return songs
          ..sort((a, b) =>
              '${a.track}${a.title}'.compareTo('${b.track}${b.title}'));
      case OrderBy.RecentlyAdded:
        return songs..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      default:
        throw Exception('Invalid order.');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Song> sortedSongs = sortSongs(orderBy: _sortOrder);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          AppBar(
            headingText: widget.album.name,
            actions: [
              IconButton(
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        title: Text('Sort by'),
                        actions: _sortOptions.entries
                            .map(
                              (entry) => CupertinoActionSheetAction(
                                onPressed: () {
                                  _currentSortOrder = entry.key;
                                  setState(() => _sortOrder = entry.key);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  (entry.key == _currentSortOrder
                                          ? '✓ '
                                          : ' ') +
                                      entry.value,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                  icon: Icon(CupertinoIcons.sort_down)),
            ],
            backgroundImage: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.album.image,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ),
            coverImage: Hero(
              tag: "album-hero-${widget.album.id}",
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.album.image,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16),
                  ),
                  boxShadow: const <BoxShadow>[
                    const BoxShadow(
                      color: Colors.black38,
                      blurRadius: 10.0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SongListButtons(songs: songs)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) => SongRow(song: songs[index]),
              childCount: songs.length,
            ),
          ),
          SliverToBoxAdapter(child: bottomSpace()),
        ],
      ),
    );
  }
}

void gotoDetailsScreen(BuildContext context, {required Album album}) {
  Navigator.of(context).push(CupertinoPageRoute<void>(
    builder: (_) => AlbumDetailsScreen(album: album),
    title: album.name,
  ));
}

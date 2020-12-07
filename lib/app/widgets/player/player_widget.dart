import 'package:flowpdc_app/app/shared/models/podcast.dart';
import 'package:flowpdc_app/app/widgets/player/player_controller.dart';
import 'package:flowpdc_app/app/widgets/player/position_seek_widget.dart';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

class PlayerWidget extends StatefulWidget {
  final Podcast podcast;

  const PlayerWidget({Key key, this.podcast}) : super(key: key);
  @override
  _PlayerWidget createState() => new _PlayerWidget();
}

class _PlayerWidget extends ModularState<PlayerWidget, PlayerController> {
  final _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
  String _currentAudio;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: Border(
              top: BorderSide(width: 1.0, color: Colors.white),
            ),
          ),
          margin: EdgeInsets.all(0),
          child: Observer(
            builder: (_) {
              if (_currentAudio == null)
                _currentAudio = widget.podcast.audioUrl;
              else if (_currentAudio != widget.podcast.audioUrl) {
                _currentAudio = widget.podcast.audioUrl;
                _assetsAudioPlayer.stop();
                _assetsAudioPlayer.open(
                  Audio.network(
                    widget.podcast.audioUrl,
                    metas: Metas(
                      title: widget.podcast.title,
                      image: MetasImage.network(widget.podcast.thumbnailUrl),
                    ),
                  ),
                  autoStart: true,
                  showNotification: true,
                  notificationSettings: NotificationSettings(
                    nextEnabled: false,
                    prevEnabled: false
                  )
                );
              }
              return Container(
                margin: EdgeInsets.only(left: 18, right: 18, bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Image.network(
                      widget.podcast.thumbnailUrl,
                      width: 80,
                      fit: BoxFit.fill,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: StreamBuilder(
                            stream: _assetsAudioPlayer.realtimePlayingInfos,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox();
                              }
                              RealtimePlayingInfos infos = snapshot.data;
                              return PositionSeekWidget(
                                seekTo: (to) {
                                  _assetsAudioPlayer.seek(to);
                                },
                                duration: infos.duration,
                                currentPosition: infos.currentPosition,
                              );
                            },
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      widget.podcast.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(0),
                              child: IconButton(
                                icon: Icon(
                                  !controller.isPlaying.value
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 38,
                                ),
                                onPressed: () {
                                  if (_assetsAudioPlayer.current.value !=
                                      null) {
                                    controller.isPlaying =
                                        ObservableFuture.value(
                                            _assetsAudioPlayer.isPlaying.value);
                                    _assetsAudioPlayer.playOrPause();
                                  }
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: Theme.of(context).accentColor,
                                  size: 38,
                                ),
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

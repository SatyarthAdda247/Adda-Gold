import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/content.dart';

class ReelCard extends StatefulWidget {
  final ReelItem reel;
  final bool isActive;
  final bool liked;
  final bool bookmarked;
  final bool muted;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleMute;

  const ReelCard({
    super.key,
    required this.reel,
    required this.isActive,
    required this.liked,
    required this.bookmarked,
    required this.muted,
    required this.onToggleLike,
    required this.onToggleBookmark,
    required this.onToggleMute,
  });

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  DateTime? _lastTap;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.reel.videoUrl),
        httpHeaders: {
          'Accept': 'video/*',
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
        },
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );
      
      _videoController!.initialize().then((_) {
        if (!mounted) return;
        if (_videoController == null || !_videoController!.value.isInitialized) {
          return;
        }
        
        final aspectRatio = _videoController!.value.aspectRatio;
        if (aspectRatio == 0 || aspectRatio.isNaN || aspectRatio.isInfinite) {
          // Default to 9:16 for reels if aspect ratio is invalid
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: widget.isActive,
            looping: true,
            showControls: false,
            aspectRatio: 9 / 16,
            allowFullScreen: false,
            allowMuting: true,
          );
        } else {
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: widget.isActive,
            looping: true,
            showControls: false,
            aspectRatio: aspectRatio,
            allowFullScreen: false,
            allowMuting: true,
          );
        }
        
        if (widget.muted) {
          _videoController!.setVolume(0);
        } else {
          _videoController!.setVolume(1);
        }
        
        _videoController!.addListener(_updateProgress);
        
        if (mounted) {
          setState(() {});
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {});
        }
      });
      
      _videoController!.addListener(() {
        if (_videoController != null && _videoController!.value.hasError) {
          if (mounted) {
            setState(() {});
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _updateProgress() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        _progress = _videoController!.value.position.inMilliseconds /
            _videoController!.value.duration.inMilliseconds;
      });
    }
  }

  @override
  void didUpdateWidget(ReelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reel.videoUrl != oldWidget.reel.videoUrl) {
      _disposeVideo();
      _initializeVideo();
    }
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive && _chewieController != null) {
        _chewieController!.play();
      } else if (_chewieController != null) {
        _chewieController!.pause();
      }
    }
    if (widget.muted != oldWidget.muted) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        if (widget.muted) {
          _videoController!.setVolume(0);
        } else {
          _videoController!.setVolume(1);
        }
      }
    }
  }
  
  void _disposeVideo() {
    _videoController?.removeListener(_updateProgress);
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 220) {
      widget.onToggleLike();
    } else {
      widget.onToggleMute();
    }
    _lastTap = now;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _videoController != null && 
                     _videoController!.value.hasError;
    final isInitialized = _videoController != null && 
                          _videoController!.value.isInitialized;
    
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasError)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load video',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your internet connection',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else if (_chewieController != null && isInitialized)
            Chewie(controller: _chewieController!)
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading video...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 18,
            right: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reel.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.reel.source != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.reel.source!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            right: 18,
            child: Column(
              children: [
                _buildActionButton(
                  icon: widget.liked ? Icons.favorite : Icons.favorite_border,
                  label: 'Like',
                  active: widget.liked,
                  onTap: widget.onToggleLike,
                ),
                const SizedBox(height: 18),
                _buildActionButton(
                  icon: widget.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  label: 'Save',
                  active: widget.bookmarked,
                  onTap: widget.onToggleBookmark,
                ),
                const SizedBox(height: 18),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {},
                ),
                const SizedBox(height: 18),
                _buildActionButton(
                  icon: widget.muted ? Icons.volume_off : Icons.volume_up,
                  label: widget.muted ? 'Muted' : 'Sound',
                  onTap: widget.onToggleMute,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: active ? Theme.of(context).colorScheme.primary : Colors.white,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


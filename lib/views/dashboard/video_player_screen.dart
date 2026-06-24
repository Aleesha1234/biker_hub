import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../utils/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String description;
  final List<String> steps;
  final String duration;
  final Color color;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.steps,
    required this.duration,
    required this.color,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _isLoading = true;
  bool _hasError = false;
  int _completedSteps = 0;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _videoCtrl = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _videoCtrl!.initialize();

      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.black,
          handleColor: Colors.black,
          bufferedColor: Colors.black.withOpacity(0.3),
          backgroundColor: Colors.grey.shade300,
        ),
        placeholder: Container(
          color: Colors.black.withOpacity(0.1),
          child: Center(
            child: const Icon(Icons.play_circle_rounded,
                color: Colors.black, size: 60),
          ),
        ),
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _videoCtrl?.dispose();
    _chewieCtrl?.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      body: Column(
        children: [
          // ── Video Player ─────────────────────────────
          _buildVideoSection(),
          // ── Content ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info ───────────────────────────
                  _buildVideoInfo(),
                  // ── Steps ──────────────────────────
                  _buildStepsSection(),
                  // ── Tips ───────────────────────────
                  _buildTipsSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Video Section ───────────────────────────────────────
  Widget _buildVideoSection() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // AppBar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  Expanded(
                    child: Text(widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // Video
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isLoading
                ? Container(
                    color: Colors.black87,
                    child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.black,
                      ),
                    ),
                  )
                : _hasError
                    ? Container(
                        color: Colors.black87,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        const Icon(Icons.play_circle_rounded, color: Colors.black, size: 60),
                            const SizedBox(height: 12),
                            const Text("Tap to play video",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      )
                    : Chewie(controller: _chewieCtrl!),
          ),
        ],
      ),
    );
  }

  // ─── Video Info ──────────────────────────────────────────
  Widget _buildVideoInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + level
          Row(
            children: [
              Expanded(
                child: Text(widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: BikerColors.black,
                    )),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
            child: const Text("Beginner",
                style: TextStyle(
                  color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.5,
              )),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              _buildInfoChip(
                  Icons.access_time_rounded, widget.duration, widget.color),
              const SizedBox(width: 10),
              _buildInfoChip(Icons.list_rounded, "${widget.steps.length} steps",
                  widget.color),
              const SizedBox(width: 10),
              _buildInfoChip(Icons.check_circle_rounded,
                  "$_completedSteps done", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  // ─── Steps Section ───────────────────────────────────────
  Widget _buildStepsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                  color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Step by Step Guide",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: BikerColors.black,
                      )),
                ]),
                Text("$_completedSteps/${widget.steps.length}",
                style: const TextStyle(
                  color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    )),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.steps.isEmpty
                    ? 0
                    : _completedSteps / widget.steps.length,
                backgroundColor: Colors.black.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation(Colors.black),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Steps list
          ...widget.steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isDone = i < _completedSteps;
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isDone) {
                    _completedSteps = i;
                  } else if (i == _completedSteps) {
                    _completedSteps++;
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDone
                  ? Colors.black.withOpacity(0.06)
                      : BikerColors.greyLt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone
                    ? Colors.black.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    // Step number / check
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                    color: isDone ? Colors.black : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                          isDone ? Colors.black : const Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : Text("${i + 1}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: i == _completedSteps
                                  ? Colors.black
                                      : Colors.grey,
                                )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(step,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDone ? BikerColors.black : Colors.grey,
                            fontWeight:
                                isDone ? FontWeight.w600 : FontWeight.w400,
                            decoration: isDone ? null : null,
                          )),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          // Complete button
          if (_completedSteps == widget.steps.length)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon:
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: const Text("Tutorial Complete! 🎉",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completedSteps < widget.steps.length
                    ? () => setState(() => _completedSteps++)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Mark Step ${_completedSteps + 1} Done",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Tips Section ────────────────────────────────────────
  Widget _buildTipsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.lightbulb_rounded, color: Colors.black, size: 18),
            const SizedBox(width: 8),
            const Text("Pro Tips",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                )),
          ]),
          const SizedBox(height: 10),
          _buildTip("Always use correct tools for the job"),
          _buildTip("Watch video completely before starting"),
          _buildTip("Keep spare parts ready beforehand"),
          _buildTip("If unsure, consult a mechanic"),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Colors.black, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tip,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  height: 1.4,
                )),
          ),
        ],
      ),
    );
  }
}

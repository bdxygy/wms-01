import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../generated/app_localizations.dart';

/// Photo viewer widget for displaying and managing captured photos
class PhotoViewer extends StatefulWidget {
  final File imageFile;
  final String? title;
  final List<Widget>? actions;
  final bool allowZoom;
  final bool showInfo;
  final VoidCallback? onDelete;

  const PhotoViewer({
    super.key,
    required this.imageFile,
    this.title,
    this.actions,
    this.allowZoom = true,
    this.showInfo = true,
    this.onDelete,
  });

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  bool _showOverlay = true;
  PhotoViewController? _photoViewController;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
  }

  @override
  void dispose() {
    _photoViewController?.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  void _showImageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.imageInfo),
        content: FutureBuilder<FileStat>(
          future: widget.imageFile.stat(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final stat = snapshot.data!;
            final sizeKB = (stat.size / 1024).toStringAsFixed(1);
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppLocalizations.of(context)!.fileName}: ${widget.imageFile.path.split('/').last}'),
                const SizedBox(height: 8),
                Text('${AppLocalizations.of(context)!.fileSize}: $sizeKB KB'),
                const SizedBox(height: 8),
                Text('${AppLocalizations.of(context)!.dateModified}: ${_formatDateTime(stat.modified)}'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePhoto),
        content: Text(AppLocalizations.of(context)!.deletePhotoConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete?.call();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showOverlay
          ? AppBar(
              title: Text(widget.title ?? l10n.photoViewer),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              actions: [
                if (widget.showInfo)
                  IconButton(
                    onPressed: _showImageInfo,
                    icon: const Icon(Icons.info_outline),
                    tooltip: l10n.imageInfo,
                  ),
                if (widget.onDelete != null)
                  IconButton(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.deletePhoto,
                  ),
              ],
            )
          : null,
      body: Stack(
        children: [
          // Photo view
          GestureDetector(
            onTap: _toggleOverlay,
            child: widget.allowZoom
                ? PhotoView(
                    imageProvider: FileImage(widget.imageFile),
                    controller: _photoViewController,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3.0,
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: widget.imageFile.path,
                    ),
                    loadingBuilder: (context, event) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.failedToLoadImage,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.failedToLoadImage,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Bottom actions overlay
          if (_showOverlay && widget.actions != null && widget.actions!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.actions!,
                ),
              ),
            ),

          // Zoom controls (if enabled)
          if (_showOverlay && widget.allowZoom)
            Positioned(
              bottom: widget.actions != null ? 100 : 20,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    onPressed: () {
                      _photoViewController?.scale = 
                          (_photoViewController?.scale ?? 1.0) * 1.2;
                    },
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.zoom_in),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    onPressed: () {
                      _photoViewController?.scale = 
                          (_photoViewController?.scale ?? 1.0) * 0.8;
                    },
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.zoom_out),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    onPressed: () {
                      _photoViewController?.scale = 1.0;
                    },
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.fullscreen_exit),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
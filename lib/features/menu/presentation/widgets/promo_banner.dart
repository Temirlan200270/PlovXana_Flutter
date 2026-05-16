import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/promotion.dart';

class PromoBanner extends StatefulWidget {
  final List<Promotion> promotions;
  const PromoBanner({super.key, required this.promotions});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  static const BorderRadius _archRadius = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
    bottomLeft: Radius.circular(16),
    bottomRight: Radius.circular(16),
  );

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: widget.promotions.length,
            itemBuilder: (_, i) {
              final p = widget.promotions[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: _archRadius,
                  child: p.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: p.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: (_, _, _) => _fallback(p),
                        )
                      : _fallback(p),
                ),
              );
            },
          ),
        ),
        if (widget.promotions.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.promotions.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _page == i ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _page == i ? AppColors.primary : AppColors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _fallback(Promotion p) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          left: BorderSide(
            color: AppColors.accentBlue.withValues(alpha: 0.8),
            width: 3,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            p.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.cream, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChanged;
  final VoidCallback? onFilterTap;
  final bool autofocus;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onFilterTap,
    this.autofocus = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        onChanged: (val) {
          widget.onChanged(val);
          setState(() {}); // to update clear button visibility
        },
        style: const TextStyle(color: AppColors.whiteColor),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(color: AppColors.subtitleText),
          prefixIcon: const Icon(Icons.search, color: AppColors.gradient1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.subtitleText, size: 20),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                ),
              if (widget.onFilterTap != null)
                IconButton(
                  icon: const Icon(Icons.tune, color: AppColors.whiteColor),
                  onPressed: widget.onFilterTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

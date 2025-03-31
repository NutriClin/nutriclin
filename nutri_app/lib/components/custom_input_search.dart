import 'package:flutter/material.dart';

class CustomInputSearch extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const CustomInputSearch({
    super.key,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  _CustomInputSearchState createState() => _CustomInputSearchState();
}

class _CustomInputSearchState extends State<CustomInputSearch> {
  bool _showClearIcon = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_updateClearIcon);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_updateClearIcon);
    super.dispose();
  }

  void _updateClearIcon() {
    setState(() {
      _showClearIcon = widget.controller?.text.isNotEmpty ?? false;
    });
  }

  void _clearSearch() {
    widget.controller?.clear();
    _updateClearIcon();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 2.5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _showClearIcon
                      ? GestureDetector(
                          onTap: _clearSearch,
                          child: const Icon(Icons.clear, color: Colors.grey),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

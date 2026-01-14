import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshTool extends StatefulWidget {
  final RefreshController? controller;
  final int? itemNum;
  final bool enUseUpPull;
  final bool enUseDownPull;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final VoidCallback? onRetry;
  final Widget child;

  const RefreshTool({
    super.key,
    this.controller,
    this.itemNum = 0,
    this.enUseUpPull = true,
    this.enUseDownPull = false,
    this.onRefresh,
    this.onLoading,
    this.onRetry,
    required this.child,
  });

  @override
  State<RefreshTool> createState() => _RefreshToolState();
}

class _RefreshToolState extends State<RefreshTool> {
  late int? _pageNum = widget.itemNum;
  late final RefreshController _controller =
      widget.controller ?? RefreshController();

  @override
  void didUpdateWidget(covariant RefreshTool oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _pageNum = widget.itemNum;
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _controller,
      header: refreshHeader(),
      onRefresh: widget.onRefresh,
      onLoading: widget.onLoading,
      enablePullUp: widget.enUseUpPull,
      enablePullDown: widget.enUseDownPull,
      child: _contentView(),
    );
  }

  Widget refreshHeader() {
    return WaterDropHeader(
      waterDropColor: Colors.transparent,
      refresh: const CupertinoActivityIndicator(color: Colors.grey, radius: 13),
      complete: Container(),
      completeDuration: const Duration(seconds: 0),
    );
  }

  Widget _contentView() {
    if (_pageNum == null) {
      return Container();
    } else {
      return widget.child;
    }
  }
}

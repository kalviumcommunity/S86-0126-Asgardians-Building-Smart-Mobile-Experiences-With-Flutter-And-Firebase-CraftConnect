import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/return_provider.dart';
import '../../models/return_request_model.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

class AdminReturnManagementScreen extends StatefulWidget {
  const AdminReturnManagementScreen({super.key});

  @override
  State<AdminReturnManagementScreen> createState() =>
      _AdminReturnManagementScreenState();
}

class _AdminReturnManagementScreenState
    extends State<AdminReturnManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    final returnProvider = Provider.of<ReturnProvider>(context, listen: false);
    await returnProvider.loadAllReturns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final returnProvider = Provider.of<ReturnProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Pending (${returnProvider.pendingReturns.length})',
            ),
            Tab(
              text: 'Approved (${returnProvider.approvedReturns.length})',
            ),
            Tab(
              text: 'Completed (${returnProvider.completedReturns.length})',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReturns,
        child: returnProvider.isLoading
            ? const LoadingStateWidget(message: 'Loading returns...')
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildReturnsList(returnProvider.pendingReturns),
                  _buildReturnsList(returnProvider.approvedReturns),
                  _buildReturnsList(returnProvider.completedReturns),
                ],
              ),
      ),
    );
  }

  Widget _buildReturnsList(List<ReturnRequestModel> returns) {
    if (returns.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.assignment_return,
        title: 'No Returns',
        message: 'No return requests in this category',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: returns.length,
      itemBuilder: (context, index) {
        final returnRequest = returns[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ExpansionTile(
            title: Text(
              'Return #${returnRequest.returnId.substring(0, 8)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(returnRequest.productName),
                const SizedBox(height: 4),
                Text(
                  returnRequest.reasonText,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: _buildStatusChip(returnRequest.status),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Order ID', returnRequest.orderId),
                    _buildInfoRow('User ID', returnRequest.userId),
                    _buildInfoRow(
                      'Refund Amount',
                      '₹${returnRequest.refundAmount.toStringAsFixed(2)}',
                    ),
                    _buildInfoRow(
                      'Requested On',
                      _formatDate(returnRequest.requestedAt),
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Description:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(returnRequest.description),
                    if (returnRequest.adminNotes != null) ...[
                      const Divider(height: 24),
                      const Text(
                        'Admin Notes:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(returnRequest.adminNotes!),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    if (returnRequest.status == ReturnStatus.requested)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showApproveDialog(returnRequest),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showRejectDialog(returnRequest),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (returnRequest.status == ReturnStatus.approved)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _completeReturn(returnRequest),
                          icon: const Icon(Icons.done_all),
                          label: const Text('Mark as Completed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ReturnStatus status) {
    Color color;
    switch (status) {
      case ReturnStatus.requested:
        color = AppTheme.warningColor;
        break;
      case ReturnStatus.approved:
        color = AppTheme.successColor;
        break;
      case ReturnStatus.rejected:
        color = AppTheme.errorColor;
        break;
      case ReturnStatus.completed:
      case ReturnStatus.refunded:
        color = AppTheme.primaryColor;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showApproveDialog(ReturnRequestModel returnRequest) async {
    final notesController = TextEditingController();

    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Return'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Admin Notes (Optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (approved == true && mounted) {
      final provider = Provider.of<ReturnProvider>(context, listen: false);
      await provider.approveReturn(
        returnRequest.returnId,
        adminNotes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );
    }

    notesController.dispose();
  }

  Future<void> _showRejectDialog(ReturnRequestModel returnRequest) async {
    final notesController = TextEditingController();

    final rejected = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Return'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Reason for Rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (rejected == true && mounted) {
      final provider = Provider.of<ReturnProvider>(context, listen: false);
      await provider.rejectReturn(
        returnRequest.returnId,
        adminNotes: notesController.text.trim(),
      );
    }

    notesController.dispose();
  }

  Future<void> _completeReturn(ReturnRequestModel returnRequest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Return'),
        content: const Text(
          'Mark this return as completed? This will process the refund.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<ReturnProvider>(context, listen: false);
      await provider.completeReturn(returnRequest.returnId);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

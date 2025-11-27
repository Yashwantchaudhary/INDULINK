import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../widgets/common/premium_widgets.dart';
import '../../widgets/common/file_attachment_picker.dart';
import '../../providers/rfq_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/rfq.dart';
import '../../services/file_upload_service.dart';
import 'modern_rfq_details_screen.dart';

/// Modern RFQ (Request for Quotation) List Screen - Integrated with Real Data
class ModernRFQListScreen extends ConsumerStatefulWidget {
  const ModernRFQListScreen({super.key});

  @override
  ConsumerState<ModernRFQListScreen> createState() =>
      _ModernRFQListScreenState();
}

class _ModernRFQListScreenState extends ConsumerState<ModernRFQListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load RFQs on init
    Future.microtask(() {
      ref.read(rfqProvider.notifier).getRFQs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rfqState = ref.watch(rfqProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: AppConstants.paddingAll20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request for Quotation',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            authState.user?.role == 'buyer'
                                ? 'Get quotes from multiple suppliers'
                                : 'View and respond to RFQ requests',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Quoted'),
                  Tab(text: 'Awarded'),
                ],
              ),
            ),
          ];
        },
        body: rfqState.isLoading && rfqState.rfqs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildRFQList(null),
                  _buildRFQList('pending'),
                  _buildRFQList('quoted'),
                  _buildRFQList('awarded'),
                ],
              ),
      ),
      floatingActionButton: authState.user?.role == 'buyer'
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateRFQDialog(),
              icon: const Icon(Icons.add),
              label: const Text('New RFQ'),
              backgroundColor: AppColors.primaryBlue,
            )
          : null,
    );
  }

  Widget _buildRFQList(String? filter) {
    final rfqState = ref.watch(rfqProvider);
    
    final filteredRFQs = filter == null
        ? rfqState.rfqs
        : rfqState.rfqs.where((rfq) => rfq.status == filter).toList();

    if (filteredRFQs.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.request_quote,
        title: 'No RFQs Found',
        message: 'Create an RFQ to get quotes from suppliers',
        actionText: 'Create RFQ',
        onAction: _showCreateRFQDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(rfqProvider.notifier).getRFQs();
      },
      child: ListView.builder(
        padding: AppConstants.paddingAll16,
        itemCount: filteredRFQs.length,
        itemBuilder: (context, index) {
          return _buildRFQCard(filteredRFQs[index]);
        },
      ),
    );
  }

  Widget _buildRFQCard(RFQ rfq) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(rfq.status).withOpacity(0.05),
            _getStatusColor(rfq.status).withOpacity(0.02),
          ],
        ),
        borderRadius: AppConstants.borderRadiusLarge,
        border: Border.all(
          color: _getStatusColor(rfq.status).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRFQDetails(rfq),
          borderRadius: AppConstants.borderRadiusLarge,
          child: Padding(
            padding: AppConstants.paddingAll16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(rfq.status),
                            _getStatusColor(rfq.status).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: AppConstants.borderRadiusSmall,
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(rfq.status).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.request_quote,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rfq.description != null && rfq.description!.isNotEmpty
                                ? rfq.description!.split('\n').first
                                : 'RFQ Request',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'RFQ #${rfq.id.substring(0, 8)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: rfq.status, isSmall: false),
                  ],
                ),
                const SizedBox(height: 16),

                // Details
                Container(
                  padding: AppConstants.paddingAll12,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant.withOpacity(0.5)
                        : AppColors.lightSurfaceVariant.withOpacity(0.5),
                    borderRadius: AppConstants.borderRadiusSmall,
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.inventory_2_outlined,
                        'Products',
                        '${rfq.products.length} items',
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.shopping_cart,
                        'Quantity',
                        '${rfq.quantity}',
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.attach_money,
                        'Ideal Price',
                        rfq.idealPrice != null ? '\$${rfq.idealPrice!.toStringAsFixed(2)}' : 'Not specified',
                        theme,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Delivery Date',
                        rfq.deliveryDate != null ? dateFormat.format(rfq.deliveryDate!) : 'Not specified',
                        theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quotes Summary
                if (rfq.quotes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: AppConstants.borderRadiusSmall,
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_offer,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${rfq.quotes.length} quotes received',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRFQDetails(rfq),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (rfq.status == 'pending')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditRFQDialog(rfq),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.lightTextSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.statusPending;
      case 'quoted':
        return AppColors.statusProcessing;
      case 'awarded':
        return AppColors.statusDelivered;
      case 'closed':
        return AppColors.lightTextTertiary;
      default:
        return AppColors.primaryBlue;
    }
  }

  void _showCreateRFQDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    List<File> selectedFiles = [];
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightTextTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create RFQ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your requirements in detail',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity Required',
                    hintText: 'E.g., 100',
                    prefixIcon: Icon(Icons.production_quantity_limits),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ideal Price',
                    hintText: 'Your budget for this RFQ',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 24),

                // File Attachment Picker
                FileAttachmentPicker(
                  onFilesSelected: (files) {
                    setModalState(() {
                      selectedFiles = files;
                    });
                  },
                  maxFiles: 3,
                  allowImages: true,
                  allowDocuments: true,
                  title: 'Attachments (Optional)',
                ),

                const SizedBox(height: 24),
               AnimatedButton(
                  text: isLoading ? 'Creating...' : 'Submit RFQ',
                  icon: isLoading ? null : Icons.send,
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (descriptionController.text.isEmpty ||
                              quantityController.text.isEmpty ||
                              priceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all required fields'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setModalState(() {
                            isLoading = true;
                          });

                          try {
                            List<Map<String, dynamic>> attachments = [];

                            // Upload files if any
                            if (selectedFiles.isNotEmpty) {
                              final fileService = FileUploadService();
                              attachments =
                                  await fileService.uploadRFQAttachments(
                                selectedFiles,
                              );
                            }

                            // Create RFQ with attachments
                            await ref.read(rfqProvider.notifier).createRFQ(
                                  products: [], // TODO: Add product selection
                                  idealPrice: double.parse(priceController.text),
                                  quantity: int.parse(quantityController.text),
                                  deliveryDate: DateTime.now()
                                      .add(const Duration(days: 30)),
                                  description: descriptionController.text,
                                  attachments: attachments.map((a) => a['url'] as String).toList(),
                                );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('RFQ created successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() {
                              isLoading = false;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  gradient: AppColors.primaryGradient,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditRFQDialog(RFQ rfq) {
    // TODO: Implement edit RFQ
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit RFQ feature coming soon')),
    );
  }

  void _showRFQDetails(RFQ rfq) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModernRFQDetailsScreen(rfqId: rfq.id),
      ),
    );
  }
}

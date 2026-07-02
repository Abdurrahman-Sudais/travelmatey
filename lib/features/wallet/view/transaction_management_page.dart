import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelmateeee/core/theme/app_colors.dart';
import 'package:travelmateeee/shared/widgets/emergency_sos.dart';
import 'package:travelmateeee/data/repositories/wallet_repository.dart';

enum _TxStatus { completed, held, pending }

class _Transaction {
  final String id;
  final String title;
  final String date;
  final _TxStatus status;
  final String amount;
  final bool isCredit;
  final String type; // CREDIT / DEBIT

  const _Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.amount,
    required this.isCredit,
    required this.type,
  });
}

class TransactionManagementPage extends StatefulWidget {
  const TransactionManagementPage({super.key});

  @override
  State<TransactionManagementPage> createState() =>
      _TransactionManagementPageState();
}

class _TransactionManagementPageState
    extends State<TransactionManagementPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _isLoading = true;

  List<_Transaction> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final repo = Get.find<WalletRepository>();
      final raw = await repo.getTransactions();
      setState(() {
        _allTransactions = raw.map((m) {
          final statusStr = (m['status'] ?? 'completed').toString().toLowerCase();
          _TxStatus status;
          switch (statusStr) {
            case 'held':
              status = _TxStatus.held;
              break;
            case 'pending':
              status = _TxStatus.pending;
              break;
            default:
              status = _TxStatus.completed;
          }
          final typeStr = (m['type'] ?? 'credit').toString().toUpperCase();
          final isCredit = typeStr == 'CREDIT';
          return _Transaction(
            id: m['id']?.toString() ?? '',
            title: m['title']?.toString() ?? m['description']?.toString() ?? 'Transaction',
            date: m['date']?.toString() ?? m['created_at']?.toString() ?? '',
            status: status,
            amount: m['amount']?.toString() ?? '₦0',
            isCredit: isCredit,
            type: typeStr,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to load transactions: $e',
        backgroundColor: kErrorRed,
        colorText: Colors.white,
      );
    }
  }

  List<_Transaction> get _filtered {
    if (_query.isEmpty) return _allTransactions;
    final q = _query.toLowerCase();
    return _allTransactions
        .where((t) =>
            t.title.toLowerCase().contains(q) ||
            t.id.toLowerCase().contains(q) ||
            t.type.toLowerCase().contains(q))
        .toList();
  }

  String get _totalLabel {
    // Sum only credit transactions for display (matches screenshot "Total")
    int sum = 0;
    for (final t in _filtered) {
      final raw = t.amount.replaceAll(RegExp(r'[₦+\-,]'), '');
      final val = int.tryParse(raw) ?? 0;
      if (t.isCredit) sum += val;
    }
    return '₦${_formatInt(sum)}';
  }

  String _formatInt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _exportCsv() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting CSV…')),
    );
  }

  void _exportTxt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting TXT…')),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _filterChipRow('Status', ['All', 'Completed', 'Held', 'Pending']),
            const SizedBox(height: 14),
            _filterChipRow('Type', ['All', 'Credit', 'Debit']),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kPrimaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Apply',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChipRow(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: Colors.black54)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options
              .map((o) => FilterChip(
                    label: Text(o),
                    selected: o == 'All',
                    onSelected: (_) {},
                    selectedColor: kPrimaryBlue.withValues(alpha: 0.15),
                  ))
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return SosScaffold(
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
              child: Column(
                children: [
                  // ── Top bar ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: const Icon(Icons.arrow_back,
                              size: 22, color: Colors.black87),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Transaction Management',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: kPrimaryBlue),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadTransactions,
                            child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 14),
                                const Icon(Icons.search,
                                    color: Colors.black38, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    onChanged: (v) =>
                                        setState(() => _query = v),
                                    style: const TextStyle(fontSize: 14),
                                    decoration: const InputDecoration(
                                      hintText: 'Search transactions...',
                                      hintStyle: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 14),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                // Filters button
                                GestureDetector(
                                  onTap: _showFilters,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.filter_list,
                                            color: kPrimaryBlue, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Filters',
                                          style: TextStyle(
                                            color: kPrimaryBlue,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Export buttons
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _exportCsv,
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: kPrimaryBlue,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.download,
                                            color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Export CSV',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _exportTxt,
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: kPrimaryGreen,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.download,
                                            color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Export TXT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Count + Total row
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${filtered.length} of '
                                  '${_allTransactions.length} transactions',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54),
                                ),
                                Text(
                                  'Total: $_totalLabel',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Transaction list
                          ...filtered.map(_txCard),
                        ],
                      ),
                    ),
                  ),
                  ),
                ],
              )),
      ),
    );
  }

  Widget _txCard(_Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        tx.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(tx.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tx.amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: tx.isCredit ? kPrimaryGreen : kErrorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Invalid Date • Invalid Date',
                style: const TextStyle(
                    fontSize: 11.5, color: Colors.black45),
              ),
              const SizedBox(width: 8),
              _typeBadge(tx.type, tx.isCredit),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${tx.id}',
            style: const TextStyle(fontSize: 11, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(_TxStatus status) {
    String label;
    Color bg;
    Color text;
    switch (status) {
      case _TxStatus.completed:
        label = 'COMPLETED';
        bg = kPrimaryGreen.withValues(alpha: 0.12);
        text = kPrimaryGreen;
        break;
      case _TxStatus.held:
        label = 'HELD';
        bg = kPrimaryBlue.withValues(alpha: 0.12);
        text = kPrimaryBlue;
        break;
      case _TxStatus.pending:
        label = 'PENDING';
        bg = kAmber.withValues(alpha: 0.15);
        text = kAmber;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: text)),
    );
  }

  Widget _typeBadge(String type, bool isCredit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        type,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black54),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/data/user_model.dart';
import '../../tickets/bloc/ticket_bloc.dart';
import '../../tickets/bloc/ticket_state.dart';
import '../../tickets/data/ticket_model.dart';

class DashboardContent extends StatelessWidget {
  final UserModel? user;
  final Function(int tabIndex)? onNavigateTab;

  const DashboardContent({super.key, this.user, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Color(0xFF4F46E5);
    const bgColor = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE0E7FF),
              child: Text(
                (user?.name.isNotEmpty ?? false)
                    ? user!.name[0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                  color: primaryIndigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WELCOME BACK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  '${user?.name ?? "Customer"} 👋',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          List<TicketModel> allTickets = [];
          if (state is TicketLoaded) {
            allTickets = state.tickets;
          }

          // Compute dynamic statistics from TicketBloc
          final openCount = allTickets.where((t) => t.status == 'Open').length;
          final inProgressCount = allTickets
              .where((t) => t.status == 'In Progress')
              .length;
          final resolvedCount = allTickets
              .where((t) => t.status == 'Resolved' || t.status == 'Closed')
              .length;
          final totalCount = allTickets.length;

          // Filter active tickets
          final activeTickets = allTickets
              .where((t) => t.status != 'Resolved' && t.status != 'Closed')
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick AI Support Action Banner
                _buildAiBanner(context, primaryIndigo),
                const SizedBox(height: 20),

                // Support Overview (Live Stats Grid)
                _buildStatsHeader(context, totalCount),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatBox(
                      count: openCount,
                      label: 'Open',
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    _buildStatBox(
                      count: inProgressCount,
                      label: 'In Progress',
                      color: const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    _buildStatBox(
                      count: resolvedCount,
                      label: 'Resolved',
                      color: const Color(0xFF059669),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Active Support Tickets Header & Dynamic Cards
                _buildActiveTicketsHeader(context),
                const SizedBox(height: 10),

                if (activeTickets.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 36,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No active tickets! All issues resolved.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => onNavigateTab?.call(2),
                          child: const Text(
                            '+ Create a new support ticket',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryIndigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...activeTickets.take(3).map((ticket) {
                    Color statusColor = const Color(0xFF2563EB);
                    Color statusBg = const Color(0xFFDBEAFE);

                    if (ticket.status == 'In Progress') {
                      statusColor = const Color(0xFFD97706);
                      statusBg = const Color(0xFFFEF3C7);
                    } else if (ticket.status == 'Waiting for Customer') {
                      statusColor = const Color(0xFF7C3AED);
                      statusBg = const Color(0xFFEDE9FE);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildTicketCard(
                        ticketNumber: ticket.ticketNumber,
                        status: ticket.status,
                        statusColor: statusColor,
                        statusBg: statusBg,
                        subject: ticket.subject,
                        category: ticket.category,
                        date:
                            '${ticket.updatedAt.day}/${ticket.updatedAt.month}',
                        onTap: () => onNavigateTab?.call(3),
                      ),
                    );
                  }),

                const SizedBox(height: 22),

                // Recent AI Conversations
                _buildRecentConversationsSection(context),
                const SizedBox(height: 22),

                // Knowledge Base FAQs Card
                _buildKnowledgeBaseCard(context),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAiBanner(BuildContext context, Color primaryIndigo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryIndigo.withAlpha(50),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFFDE047),
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Instant AI First-Line Help',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Have a question or sync problem?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ask questions through our RAG-powered AI assistant anytime.',
                      style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Start Live AI Session',
                  style: TextStyle(
                    color: Color(0xFFE0E7FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () => onNavigateTab?.call(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ask AI Now →',
                      style: TextStyle(
                        color: Color(0xFF4338CA),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Support Overview',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        InkWell(
          onTap: () => onNavigateTab?.call(3),
          child: Text(
            'View All ($total)',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F46E5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required int count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTicketsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFD97706),
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              'Active Support Tickets',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () => onNavigateTab?.call(2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 14,
                  color: Color(0xFF4F46E5),
                ),
                SizedBox(width: 4),
                Text(
                  'New Ticket',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard({
    required String ticketNumber,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String subject,
    required String category,
    required String date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticketNumber,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentConversationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.chat_outlined, color: Color(0xFF4F46E5), size: 16),
            SizedBox(width: 4),
            Text(
              'Recent AI Conversations',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildConversationTile(
          title: 'How to configure custom webhook?',
          snippet: 'You can add webhook headers in Settings → Integrations.',
          onTap: () => onNavigateTab?.call(1),
        ),
      ],
    );
  }

  Widget _buildConversationTile({
    required String title,
    required String snippet,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    snippet,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeBaseCard(BuildContext context) {
    const primaryIndigo = Color(0xFF4F46E5);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.menu_book_rounded, size: 16, color: primaryIndigo),
                  SizedBox(width: 6),
                  Text(
                    'Popular Knowledge Base\nFAQs',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1B4B),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => onNavigateTab?.call(
                  6,
                ), // Navigates to full Knowledge Base tab
                child: const Row(
                  children: [
                    Text(
                      'Explore All',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primaryIndigo,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '→',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryIndigo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onNavigateTab?.call(6),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Reset',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Security & 2FA setup',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => onNavigateTab?.call(6),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment Sync',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Dart & Python integration',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

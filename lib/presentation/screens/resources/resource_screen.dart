import 'package:flutter/material.dart';

class ResourceScreen extends StatelessWidget {
  const ResourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Hardcoded grants for demo
    final grants = [
      {
        'title': 'Agri-Tech Innovation Grant',
        'amount': '\$50,000',
        'sector': 'Agriculture'
      },
      {
        'title': 'Sustainable Marine Fund',
        'amount': '\$25,000',
        'sector': 'Marine'
      },
      {
        'title': 'Tech Startup Booster',
        'amount': '\$10,000',
        'sector': 'Technology'
      },
      {
        'title': 'Horticulture Development Scheme',
        'amount': '\$100,000',
        'sector': 'Horticulture'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Grants'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grants.length,
        itemBuilder: (context, index) {
          final grant = grants[index];
          // Use dynamic color for the card accent
          // Note: In real app, maybe list filters based on user sector.
          // Here, we just style them.

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            grant['title']!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            grant['amount']!,
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sector: ${grant['sector']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'Closing soon',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

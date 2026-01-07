class AppStrings {
  static const List<String> all = [
    // Funding Readiness
    'Funding Readiness',
    'Team',
    'Number of Founders',
    'Founder Experience',
    'Product & Market',
    'Product Stage',
    'Idea', 'MVP', 'Live',
    'Target Customer',
    'Market Size',
    'Revenue Model',
    'Traction & Growth',
    'Active Users',
    'Monthly Revenue (₹)',
    'Active pilots?',
    'Growth Rate',
    'Low', 'Medium', 'High',
    'Previous Funding',
    'Key Partnerships?',
    'Readiness check submitted!',

    // Investor Matching
    'Investor Matching',
    'Startup Name',
    'Sector',
    // 'AgriTech', 'FinTech', 'HealthTech', 'EdTech', 'Other', // Sectors usually shouldn't be translated or should be careful? Usually yes.
    'Sub-sector',
    'Startup Stage', // Duplicate of 'Product Stage' values? No: Pre-seed, Seed, Series A
    'Pre-seed', 'Series A',
    'Series B', // Seed is in both implicitly or explicitly
    'Location',
    'Funding Amount Sought',
    'Business Model',
    'B2B', 'B2C', 'SaaS',
    'Brief Description (Optional)',
    'Find Matches',
    'Data saved successfully!',

    // Pitch Deck Analyzer
    'Pitch Deck Analyzer',
    'Tap to upload PDF or PPT',
    'Target Funding Stage',
    'Investor Type',
    'Angel', 'VC', 'Accelerator', 'Bank', 'Grant',
    'Start Analysis',
    'Please select a file first',
    'Pitch deck uploaded for analysis!'
  ];

  // Specific markers
  static const String optionalMarker = '(Optional)';
  // static const String optionalHint = '(Optional)'; // handled dynamically
}

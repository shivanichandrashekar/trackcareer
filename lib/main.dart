import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryGreen = Color(0xFF82AD98);
const Color background = Color(0xFFF5F8F3);
const Color darkText = Color(0xFF344A40);
const Color mintCard = Color(0xFFE3F0E9);
const Color softMint = Color(0xFFD5E8DC);
const Color cream = Color(0xFFFFFEFC);

void main() {
  runApp(const CareerTrackApp());
}

class CareerTrackApp extends StatelessWidget {
  const CareerTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareerTrack',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: darkText,
          elevation: 0,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class JobApplication {
  String company;
  String role;
  String location;
  String status;
  DateTime date;

  JobApplication({
    required this.company,
    required this.role,
    required this.location,
    required this.status,
    required this.date,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'All';

  final List<String> statuses = [
    'Applied',
    'Shortlisted',
    'Interview',
    'Rejected',
    'Selected',
  ];

  final List<JobApplication> applications = [
    JobApplication(
      company: 'Google',
      role: 'Software Engineer',
      location: 'Hyderabad',
      status: 'Shortlisted',
      date: DateTime(2026, 11, 2),
    ),
    JobApplication(
      company: 'Microsoft',
      role: 'Flutter Developer',
      location: 'Bangalore',
      status: 'Interview',
      date: DateTime(2026, 11, 4),
    ),
    JobApplication(
      company: 'Amazon',
      role: 'Data Analyst',
      location: 'Hyderabad',
      status: 'Applied',
      date: DateTime(2026, 11, 5),
    ),
    JobApplication(
      company: 'Deloitte',
      role: 'Graduate Analyst',
      location: 'Mumbai',
      status: 'Selected',
      date: DateTime(2026, 11, 6),
    ),
  ];
    @override
  void initState() {
    super.initState();
    loadApplications();
  }

  Future<void> saveApplications() async {
    final prefs = await SharedPreferences.getInstance();

    final data = applications.map((job) {
      return {
        'company': job.company,
        'role': job.role,
        'location': job.location,
        'status': job.status,
        'date': job.date.toIso8601String(),
      };
    }).toList();

    await prefs.setString('applications', jsonEncode(data));
  }

  Future<void> loadApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('applications');

    if (savedData == null) return;

    try {
      final List<dynamic> decodedData = jsonDecode(savedData);

      final loadedJobs = decodedData.map((item) {
        return JobApplication(
          company: item['company'],
          role: item['role'],
          location: item['location'],
          status: item['status'],
          date: DateTime.parse(item['date']),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        applications
          ..clear()
          ..addAll(loadedJobs);
      });
    } catch (e) {
      debugPrint('Error loading applications: $e');
    }
  }

  int get totalApplications => applications.length;

  int get shortlistedCount =>
      applications.where((job) => job.status == 'Shortlisted').length;

  int get interviewCount =>
      applications.where((job) => job.status == 'Interview').length;

  int get selectedCount =>
      applications.where((job) => job.status == 'Selected').length;

  int get rejectedCount =>
      applications.where((job) => job.status == 'Rejected').length;

  double get selectionRate => totalApplications == 0
      ? 0
      : (selectedCount / totalApplications) * 100;

  double get interviewRate => totalApplications == 0
      ? 0
      : (interviewCount / totalApplications) * 100;

  List<JobApplication> get filteredApplications {
    return applications.where((job) {
      final matchesSearch =
          job.company.toLowerCase().contains(searchController.text.toLowerCase()) ||
          job.role.toLowerCase().contains(searchController.text.toLowerCase());

      final matchesFilter =
          selectedFilter == 'All' || job.status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Applied':
        return const Color(0xFF83AFC1);
      case 'Shortlisted':
        return const Color(0xFF75A88A);
      case 'Interview':
        return const Color(0xFFD6A56C);
      case 'Rejected':
        return const Color(0xFFD58E8E);
      case 'Selected':
        return const Color(0xFF668E76);
      default:
        return primaryGreen;
    }
  }

  void addApplication() {
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    final locationController = TextEditingController();

    String newStatus = 'Applied';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cream,
              title: const Text(
                'Add Job Application',
                style: TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roleController,
                      decoration: const InputDecoration(
                        labelText: 'Job Role',
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: newStatus,
                      decoration: const InputDecoration(
                        labelText: 'Application Status',
                      ),
                      items: statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            newStatus = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (companyController.text.trim().isEmpty ||
                        roleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter company and job role.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      applications.insert(
                        0,
                        JobApplication(
                          company: companyController.text.trim(),
                          role: roleController.text.trim(),
                          location: locationController.text.trim().isEmpty
                              ? 'Not specified'
                              : locationController.text.trim(),
                          status: newStatus,
                          date: DateTime.now(),
                        ),
                      );
                      selectedFilter = 'All';
                      searchController.clear();
                      saveApplications();
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add Application'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: softMint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInsightCard() {
    String insight;

    if (totalApplications == 0) {
      insight = 'Add your first application to start tracking your career progress.';
    } else if (interviewCount > 0) {
      insight = 'Great progress! You have $interviewCount interview opportunity(s). Prepare well!';
    } else if (shortlistedCount > 0) {
      insight = 'You have been shortlisted $shortlistedCount time(s). Keep preparing for interviews!';
    } else if (selectedCount > 0) {
      insight = 'Congratulations! You have received $selectedCount selection(s).';
    } else {
      insight = 'Keep applying! Consistent applications can improve your opportunities.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF82AD98),
            Color(0xFFB4D2BF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Career Insight',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: softMint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Career Insights Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 18),
          Text('Interview conversion',
              style: TextStyle(color: darkText)),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: interviewRate / 100,
            minHeight: 9,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: softMint,
            color: const Color(0xFFD6A56C),
          ),
          const SizedBox(height: 5),
          Text('${interviewRate.toStringAsFixed(1)}% of applications'),
          const SizedBox(height: 18),
          Text('Selection rate', style: TextStyle(color: darkText)),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: selectionRate / 100,
            minHeight: 9,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: softMint,
            color: primaryGreen,
          ),
          const SizedBox(height: 5),
          Text('${selectionRate.toStringAsFixed(1)}% of applications'),
        ],
      ),
    );
  }

  Widget buildApplicationCard(JobApplication job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: softMint),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: mintCard,
                child: Text(
                  job.company.isEmpty ? '?' : job.company[0].toUpperCase(),
                  style: const TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.company,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    Text(
                      job.role,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete application',
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    applications.remove(job);
                    saveApplications();
                  });
                },
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.black54),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  job.location,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              DropdownButton<String>(
                value: job.status,
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(12),
                items: statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor(status),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      job.status = value;
                      saveApplications();
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = filteredApplications;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.track_changes, color: primaryGreen, size: 28),
            SizedBox(width: 9),
            Text(
              'CareerTrack',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: IconButton(
              tooltip: 'Add application',
              onPressed: addApplication,
              icon: const Icon(Icons.add_circle, color: primaryGreen, size: 30),
            ),
          ),
        ],
      ),
      
      drawer: Drawer(
        backgroundColor: cream,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: primaryGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.track_changes,
                      color: Colors.white, size: 38),
                  SizedBox(height: 10),
                  Text(
                    'CareerTrack',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Organize. Apply. Achieve.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.work_outline),
              title: const Text('My Applications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplicationsPage(
                      applications: applications,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('Career Insights'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InsightsPage(
                      total: totalApplications,
                      shortlisted: shortlistedCount,
                      interviews: interviewCount,
                      selected: selectedCount,
                      rejected: rejectedCount,
                      interviewRate: interviewRate,
                      selectionRate: selectionRate,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About CareerTrack'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AboutPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addApplication,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Job'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Keep track of your career journey.',
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 22),

              buildInsightCard(),

              const SizedBox(height: 24),
              const Text(
                'Application Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 14),

              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 650 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: columns == 4 ? 2.2 : 1.5,
                    children: [
                      buildStatCard('Total', totalApplications,
                          Icons.work_outline, primaryGreen),
                      buildStatCard('Shortlisted', shortlistedCount,
                          Icons.star_outline, const Color(0xFF75A88A)),
                      buildStatCard('Interviews', interviewCount,
                          Icons.people_outline, const Color(0xFFD6A56C)),
                      buildStatCard('Selected', selectedCount,
                          Icons.check_circle_outline, const Color(0xFF668E76)),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),
              buildProgressCard(),

              const SizedBox(height: 24),
              const Text(
                'My Applications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search company or job role...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: cream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: softMint),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: softMint),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', ...statuses].map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: selectedFilter == status,
                        selectedColor: softMint,
                        backgroundColor: cream,
                        labelStyle: TextStyle(
                          color: darkText,
                          fontWeight: selectedFilter == status
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedFilter = status;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              if (jobs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.search_off, size: 40, color: primaryGreen),
                      SizedBox(height: 10),
                      Text(
                        'No applications found.',
                        style: TextStyle(color: darkText),
                      ),
                    ],
                  ),
                )
              else
                ...jobs.map(buildApplicationCard),

              const SizedBox(height: 35),
              Center(
                child: Text(
                  'CareerTrack • Organize. Apply. Achieve.',
                  style: TextStyle(
                    color: darkText.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}  

class ApplicationsPage extends StatelessWidget {
  final List<JobApplication> applications;

  const ApplicationsPage({
    super.key,
    required this.applications,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      backgroundColor: background,
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final job = applications[index];

          return Card(
            color: cream,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: mintCard,
                child: Text(job.company[0].toUpperCase()),
              ),
              title: Text(
                job.company,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              subtitle: Text('${job.role}\n${job.location}'),
              isThreeLine: true,
              trailing: Text(
                job.status,
                style: const TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class InsightsPage extends StatelessWidget {
  final int total;
  final int shortlisted;
  final int interviews;
  final int selected;
  final int rejected;
  final double interviewRate;
  final double selectionRate;

  const InsightsPage({
    super.key,
    required this.total,
    required this.shortlisted,
    required this.interviews,
    required this.selected,
    required this.rejected,
    required this.interviewRate,
    required this.selectionRate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: const Text('Career Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Career Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount:
                  MediaQuery.of(context).size.width > 600 ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _insightCard('Total Applications', total),
                _insightCard('Shortlisted', shortlisted),
                _insightCard('Interviews', interviews),
                _insightCard('Selected', selected),
                _insightCard('Rejected', rejected),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              'Performance Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 15),
            _progressItem('Interview Conversion', interviewRate),
            const SizedBox(height: 20),
            _progressItem('Selection Rate', selectionRate),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: mintCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                total == 0
                    ? 'Start adding applications to view your career progress.'
                    : 'You have tracked $total applications. '
                        'Keep applying and preparing for new opportunities!',
                style: const TextStyle(
                  color: darkText,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightCard(String title, int value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: softMint),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
  tween: Tween<double>(
    begin: 0,
    end: value.toDouble(),
  ),
  duration: const Duration(milliseconds: 1200),
  builder: (context, animatedValue, child) {
    return Text(
      animatedValue.toInt().toString(),
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: primaryGreen,
      ),
    );
  },
),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: darkText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _progressItem(String title, double rate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: darkText)),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
  tween: Tween<double>(
    begin: 0,
    end: (rate / 100).clamp(0.0, 1.0),
  ),
  duration: const Duration(seconds: 1),
  builder: (context, value, child) {
    return LinearProgressIndicator(
      value: value,
      minHeight: 10,
      backgroundColor: softMint,
      color: primaryGreen,
      borderRadius: BorderRadius.circular(10),
    );
  },
),
        const SizedBox(height: 5),
        Text('${rate.toStringAsFixed(1)}%'),
      ],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: const Text('About CareerTrack')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              color: cream,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: mintCard,
                      child: Icon(
                        Icons.track_changes,
                        size: 45,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'CareerTrack',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Organize. Apply. Achieve.',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'CareerTrack is a Flutter-based job application '
                      'management web application designed to help '
                      'students and job seekers organize their career journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.work_outline,
                          color: primaryGreen),
                      title: Text('Job Application Management'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.insights_outlined,
                          color: primaryGreen),
                      title: Text('Career Progress Analytics'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.devices,
                          color: primaryGreen),
                      title: Text('Responsive Flutter Web Design'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.storage,
                          color: primaryGreen),
                      title: Text('Local Data Storage'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Developed using Flutter and Dart',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


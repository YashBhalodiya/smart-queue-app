import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment.dart';
import '../models/service_type.dart';
import '../widgets/appointment_card.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({Key? key}) : super(key: key);

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchController = TextEditingController();
  List<Appointment> _filteredList = [];
  String _selectedStatus = 'All';
  String _selectedService = 'All';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _filteredList = Provider.of<AppointmentProvider>(context, listen: false).appointments;
  }

  void _filter() {
    final all = Provider.of<AppointmentProvider>(context, listen: false).appointments;
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredList = all.where((a) {
        final matchesQuery = a.id.toLowerCase().contains(query) || a.name.toLowerCase().contains(query);
        final matchesStatus = _selectedStatus == 'All' || a.status == _selectedStatus;
        final matchesService = _selectedService == 'All' || a.serviceType == _selectedService;
        final matchesDate = _selectedDate == null || 
          (a.date.year == _selectedDate!.year && a.date.month == _selectedDate!.month && a.date.day == _selectedDate!.day);
        
        return matchesQuery && matchesStatus && matchesService && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _filter(),
                    decoration: InputDecoration(
                      hintText: 'Search ID or Name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedStatus,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedStatus = val);
                      _filter();
                    }
                  },
                  items: ['All', 'Scheduled', 'In Progress', 'Completed', 'Cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedService,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedService = val);
                        _filter();
                      }
                    },
                    items: ['All', ...ServiceConstants.services.map((s) => s.name)]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null ? 'Any Date' : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    setState(() => _selectedDate = date);
                    _filter();
                  },
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () {
                      setState(() => _selectedDate = null);
                      _filter();
                    },
                  )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                return AppointmentCard(appointment: _filteredList[index]);
              },
            ),
          )
        ],
      ),
    );
  }
}

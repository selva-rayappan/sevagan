enum JobStatus { pending, accepted, started, completed, cancelled }

class Job {
  final String id;
  final String customerName;
  final String serviceType;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final double price;
  final DateTime createdAt;
  JobStatus status;

  Job({
    required this.id,
    required this.customerName,
    required this.serviceType,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.createdAt,
    this.status = JobStatus.pending,
  });
}

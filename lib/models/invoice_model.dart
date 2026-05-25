enum InvoiceStatus {
  paid,
  pending,
}

class Invoice {
  final String id;
  final String studentName;
  final String rollNumber;
  final String billingMonth;
  final String amount;
  InvoiceStatus status;

  Invoice({
    required this.id,
    required this.studentName,
    required this.rollNumber,
    required this.billingMonth,
    required this.amount,
    required this.status,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? json['invoiceNumber'] ?? '',
      studentName: json['studentName'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      billingMonth: json['billingMonth'] ?? '',
      amount: 'PKR ${json['amount'] ?? 0}', // Hardcoding PKR as per schema
      status: json['status'] == 'paid' ? InvoiceStatus.paid : InvoiceStatus.pending,
    );
  }
}

// Dummy Data
List<Invoice> dummyInvoices = [
  Invoice(
    id: '#INV-2024-001',
    studentName: 'Ahmad Khan',
    rollNumber: 'Roll: 2024-001',
    billingMonth: 'May 2024',
    amount: 'PKR 6,500.00',
    status: InvoiceStatus.paid,
  ),
  Invoice(
    id: '#INV-2024-002',
    studentName: 'Sara Ahmed',
    rollNumber: 'Roll: 2024-002',
    billingMonth: 'May 2024',
    amount: 'PKR 7,000.00',
    status: InvoiceStatus.pending,
  ),
];

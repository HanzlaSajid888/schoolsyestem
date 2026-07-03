/**
 * @file FBR POS Integration Service
 * Simulates communication with the Federal Board of Revenue's Point of Sale API.
 */

/**
 * Simulates reporting an invoice to the FBR Sandbox API.
 * In a live environment, this would format the invoice data,
 * sign it with the POSID and secret token, and send an HTTP POST.
 * 
 * @param {Object} invoiceData - The invoice document to report
 * @returns {Promise<string>} - Returns an 18-digit FBR Invoice Number
 */
exports.reportInvoiceToFBR = async (invoiceData) => {
  return new Promise((resolve) => {
    // Simulate API delay (network latency)
    setTimeout(() => {
      // Generate a dummy 18-digit FBR invoice number (e.g. 100000000123456789)
      const randomPart = Math.floor(10000000 + Math.random() * 90000000).toString(); // 8 digits
      const timestampPart = Date.now().toString().slice(-10); // 10 digits
      
      const dummyFBRNumber = `${randomPart}${timestampPart}`;
      
      resolve(dummyFBRNumber);
    }, 1000);
  });
};

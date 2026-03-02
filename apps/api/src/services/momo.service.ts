export class MoMoService {
  constructor(
    private apiKey: string,
    private environment: 'sandbox' | 'production' = 'production'
  ) {}

  async requestPayment(
    amount: number,
    phone: string,
    reference: string
  ): Promise<{ transactionId: string; status: string }> {
    // MTN MoMo API integration
    return {
      transactionId: reference,
      status: 'pending',
    };
  }

  async checkPaymentStatus(transactionId: string): Promise<string> {
    return 'SUCCESSFUL';
  }
}

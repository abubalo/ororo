import { ApiClient, type ApiClientConfig, ApiError } from './client';
import { AuthEndpoints } from './endpoints/auth';
import { ShiftEndpoints } from './endpoints/shifts';
import { TransactionEndpoints } from './endpoints/transactions';
import { ProductEndpoints } from './endpoints/products';
import { CreditEndpoints } from './endpoints/credit';
import { ReportEndpoints } from './endpoints/reports';
import { StationEndpoints } from './endpoints/stations';

export class OroroApiClient {
  private client: ApiClient;

  // Endpoint groups
  public auth: AuthEndpoints;
  public shifts: ShiftEndpoints;
  public transactions: TransactionEndpoints;
  public products: ProductEndpoints;
  public credit: CreditEndpoints;
  public reports: ReportEndpoints;
  public stations: StationEndpoints;

  constructor(config: ApiClientConfig) {
    this.client = new ApiClient(config);

    // Initialize endpoint groups
    this.auth = new AuthEndpoints(this.client);
    this.shifts = new ShiftEndpoints(this.client);
    this.transactions = new TransactionEndpoints(this.client);
    this.products = new ProductEndpoints(this.client);
    this.credit = new CreditEndpoints(this.client);
    this.reports = new ReportEndpoints(this.client);
    this.stations = new StationEndpoints(this.client);
  }
}

export { ApiError };
export type { ApiClientConfig };

// Re-export types
export * from './endpoints/auth';
export * from './endpoints/shifts';
export * from './endpoints/transactions';
export * from './endpoints/products';
export * from './endpoints/credit';
export * from './endpoints/reports';
export * from './endpoints/stations';

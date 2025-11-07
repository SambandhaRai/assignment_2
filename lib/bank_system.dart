abstract class InterestBearing{
  double calculateInterest();
}

abstract class BankAccount{
  final String _accountNumber;
  String _holderName;
  double _balance;

  // Constructor
  BankAccount(this._accountNumber, this._holderName, this._balance);

  // Getter and Setter account holder name
  String get getAccountHolderName{
    return _holderName;
  }

  set setAccountHolderName(String anotherAccountHolderName){
    _holderName = anotherAccountHolderName;
  }

  // Getter and Setter account holder name
  double get getBalance{
    return _balance;
  }

  set setBalance(double anotherBalance){
    _balance = anotherBalance;
  }

  // Methods
  void withdraw(double amount);
  void deposit(double amount);

  void updateBalance(double newBalance){
    _balance = newBalance;
  }
}

class SavingsAccount extends BankAccount implements InterestBearing{
  final double _minBalance = 500;
  final double _interestRate = 0.02;
  final int _withdrawalLimit = 3;
  int _withdrawCount = 0;

  // Constructor
  SavingsAccount(super._accountNumber, super._accountHolderName, super._balance);

  // Polymorphism through overriding methods
  @override
  void deposit(double amount) {
    if(amount > 0){
      updateBalance(_balance + amount);
      print("Deposited : \$$amount to Saving Account.");
    } else{
      print("Invalid Deposit Amount.");
    }
  }

  @override
  void withdraw(double amount) {
    if(_withdrawCount >= _withdrawalLimit){
      print("Withdrawal Limit reached for this month");
    } 
    if(_balance - amount < _minBalance){
      print("Cannot withdraw below minimum balance: \$$_minBalance");
      return;
    }

    updateBalance(_balance - amount);
    _withdrawCount++;
    print("Withdrawn \$$amount from Saving Account.");
  }
  
  @override
  double calculateInterest() {
    return _balance * _interestRate;
  }
}

class CheckingAccount extends BankAccount{
  final double _overdraftFee = 35;

  // Constructor
  CheckingAccount(super._accountNumber, super._holderName, super._balance);

  // Polymorphism through overriding methods
  @override
  void deposit(double amount) {
    if(amount > 0){
      updateBalance(_balance + amount);
      print("Deposited : \$$amount to Checking Account.");
    } else{
      print("Invalid Deposit Amount.");
    }
  }

  @override
  void withdraw(double amount) {
    if(amount <= 0){
      print("Invalid amount");
    }

    updateBalance(_balance - amount);
    if(_balance < 0) {
      updateBalance(_balance - _overdraftFee);
      print("Overdraft fee of \$$_overdraftFee applied.");
    }
    print("Withdrawn \$$amount from Checking Account.");
  }
}

class PremiumAccount extends BankAccount implements InterestBearing{
  final double _minBalance = 10000;
  final double _interestRate = 0.05;

  // Constructor
  PremiumAccount(super._accountNumber, super._holderName, super._balance);

  // Polymorphism through overriding methods
  @override
  double calculateInterest() {
    return _balance * _interestRate;
  }

  @override
  void deposit(double amount) {
    if(amount > 0){
      updateBalance(_balance + amount);
      print("Deposited : \$$amount to Premium Account.");
    } else{
      print("Invalid Deposit Amount.");
    }
  }

  @override
  void withdraw(double amount) {
    if(_balance - amount < _minBalance){
      print("Cannot withdraw below minimum balance: \$$_minBalance");
      return;
    }

    updateBalance(_balance - amount);
    print("Withdrawn \$$amount from Premium Account.");
  }
}

class Bank{
  // List to store all created accounts
  List<BankAccount> accounts = [];

  // Create new account
  void createAccount(BankAccount account) {
    accounts.add(account);
    print("Account created for ${account.getAccountHolderName}.");
  }

  // Find account by account number
  BankAccount? findAccount(String accountNumber) {
    for (var account in accounts) {
      if (account._accountNumber == accountNumber) {
        return account;
      }
    }
    print("Account with number $accountNumber not found.");
    return null;
  }

  // Transfer money between two accounts
  void transfer(String fromAccount, String toAccount, double amount) {
    BankAccount? sender = findAccount(fromAccount);
    BankAccount? receiver = findAccount(toAccount);

    if (sender == null || receiver == null) {
      print("Transfer failed: Account not found.");
      return;
    }

    if (amount <= 0) {
      print("Invalid transfer amount.");
      return;
    }

    // Withdraw from sender and deposit to receiver
    double oldBalance = sender.getBalance;
    sender.withdraw(amount);

    // Only deposit if withdrawal succeeded
    if (sender.getBalance < oldBalance) {
      receiver.deposit(amount);
      print("Transferred \$$amount from ${sender.getAccountHolderName} to ${receiver.getAccountHolderName}.");
    } else {
      print("Transfer cancelled.");
    }
  }

  // Generate report of all accounts
  void generateReport() {
    print("\n========== BANK REPORT ==========");
    if (accounts.isEmpty) {
      print("No accounts found.");
      return;
    }

    for (var acc in accounts) {
      print("\nAccount Type: ${acc.runtimeType}");
      print("Account Holder: ${acc.getAccountHolderName}");
      print("Balance: \$${acc.getBalance}");

      // Only calculate interest for accounts that implement InterestBearing
      if (acc is InterestBearing) {
        print("Interest: \$${(acc as InterestBearing).calculateInterest()}");
      }

      print("----------------------------------");
    }
  }
}

void main() {
  // Create the bank
  Bank bank = Bank();

  // Create accounts
  var savings = SavingsAccount("SA1001", "Alice", 1200);
  var checking = CheckingAccount("CA1002", "Bob", 500);
  var premium = PremiumAccount("PA1003", "Charlie", 15000);

  // Add accounts to the bank
  bank.createAccount(savings);
  bank.createAccount(checking);
  bank.createAccount(premium);

  print("\n--- Performing Transactions ---");

  // Perform some deposits and withdrawals
  savings.deposit(300);       // Deposit to savings
  savings.withdraw(400);      // Withdraw from savings
  checking.deposit(200);      // Deposit to checking
  checking.withdraw(800);     // Withdraw more than balance (overdraft fee applies)
  premium.withdraw(2000);     // Withdraw from premium account

  print("\n--- Transferring Money ---");
  // Transfer money from Alice (Savings) to Bob (Checking)
  bank.transfer("SA1001", "CA1002", 100);

  print("\n--- Generating Bank Report ---");
  // Generate report of all accounts
  bank.generateReport();
}

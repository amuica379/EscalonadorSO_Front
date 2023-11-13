class Process{
    int id;
    int arrivalTime;
    int execTime;
    int deadline;
    int priority;
    int numberOfPages;

    Process({
      required this.id,
      required this.arrivalTime,
      required this.execTime,
      required this.deadline,
      this.priority= 0,
      required this.numberOfPages
    });

}
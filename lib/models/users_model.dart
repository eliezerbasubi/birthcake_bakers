class Users {
  String uid;
  String name;
  String phone;
  String email;
  String location;
  String password;
  String profileURL;

  Users({this.uid,this.name,this.phone,this.email,this.location,this.password,this.profileURL});
}

List<Users> users = [
    Users(
      uid: "1",
      name: "Eliezer Basubi Wikulukya",
      email: "eliezer.basubi30@gmail.com",
      phone: "0705845851",
      location: "Los Angeles, United States",
      password: "eliezer.basubi1234",
      profileURL: "images/profile.jpg"
    ),

    Users(
      uid: "2",
      name: "Ephrem Basubi Lunyungu",
      email: "ephrem.basubi3001@gmail.com",
      phone: "0702367980",
      location: "Kansanfa, Uganda",
      password: "ephrem.basubi1234",
      profileURL: "images/runner.png"
    ),

    Users(
      uid: "3",
      name: "Raissa Basubi Mangasa",
      email: "raissa.basubi08@gmail.com",
      phone: "0815845851",
      location: "Gombe,Kinshasa,DRC",
      password: "raissa.basubi1234",
      profileURL: "images/images(8).jpg"
    ),
];


import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class Student {
  final String fullName;
  final String email;
  final String photoUrl;

  const Student({this.fullName, this.email, this.photoUrl});
}

class _StudentListItem extends ListTile {
  _StudentListItem(Student student) :
        super(
        title : new Text(student.fullName),
        subtitle: new Text(student.email),
        leading: new CircleAvatar(
          backgroundImage: new NetworkImage(student.photoUrl),
          backgroundColor: Colors.white,
        ),
        onTap: () {
          _launchURL(student);
        },
      );
}

class StudentList extends StatelessWidget {
  final List<Student> _students;

  StudentList(this._students);

  @override
  Widget build(BuildContext context) {
    return new ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        children: _buildStudentList()
    );
  }

  List<_StudentListItem> _buildStudentList() {
    return _students.map((student) => new _StudentListItem(student))
        .toList();
  }
}

_launchURL(Student student) async {
  var url = 'mailto:' + student.email;
  print("coucou");
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}


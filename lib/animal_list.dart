import 'animal.dart';

class AnimalListController {
  final List<Animal> animals = [
    Animal(
      name: "Dog", 
      vaccineStatus: false, 
      dewormStatus: false, 
      fleaStatus: false, 
      fecalStatus: false)
    ];

  void addAnimal(String name) {
    animals.add(
      Animal(
        name: name, 
        vaccineStatus: false,
        dewormStatus: false,
        fleaStatus: false,
        fecalStatus: false
        ));
  }

  void removeAnimal(Animal animal) { //not implemented yet
    animals.remove(animal);
  }
}
#encoding:UTF-8
require 'java'
require 'base64'
require 'stringio'
require 'pp'

require_relative 'java/commons-codec-1.10'
require_relative 'java/commons-eid-client-0.6.6'
require_relative 'java/commons-eid-consumer-0.6.6'
require_relative 'java/commons-logging-1.2'

java_import "be.fedict.commons.eid.client.BeIDCard"
java_import "be.fedict.commons.eid.client.BeIDCards"
java_import "be.fedict.commons.eid.client.FileType"


java_import "be.fedict.commons.eid.consumer.Identity"
java_import "be.fedict.commons.eid.consumer.Address"
java_import "be.fedict.commons.eid.consumer.tlv.TlvParser"
class BeID
  attr_reader :active_card

  def initialize(card = nil)
    if card.nil?
      cards = BeIDCards.new
      @active_card = cards.one_be_id_card
    else
      @active_card = card
    end
  end

  def identity
    id = TlvParser.parse(@active_card.readFile(FileType::Identity), Identity)

    special_organization = {
        1 => 'SHAPE',
        2 => 'NATO',
        4 => 'Former blue card holder',
        5 => 'Researcher'
    }
    special_organization.default = 'unspecified'

    document_type = {
        1 => {id:1, code: 'BELGIAN_CITIZEN', description:''},
        6 => {id:6, code: 'KIDS_CARD', description:''},
        7 => {id:7, code: 'BOOTSTRAP_CARD', description:''},
        8 => {id:8, code: 'HABILITATION_CARD', description:''},
        11 => {id:11, code: 'FOREIGNER_A', description:'Bewijs van inschrijving in het vreemdelingenregister ??? Tijdelijk verblijf'},
        12 => {id:12, code: 'FOREIGNER_B', description:'Bewijs van inschrijving in het vreemdelingenregister'},
        13 => {id:13, code: 'FOREIGNER_C', description:'Identiteitskaart voor vreemdeling'},
        14 => {id:14, code: 'FOREIGNER_D', description:'EG-Langdurig ingezetene'},
        15 => {id:15, code: 'FOREIGNER_E', description:'(Verblijfs)kaart van een onderdaan van een lidstaat der EEG. Verklaring van inschrijving'},
        16 => {id:16, code: 'FOREIGNER_E_PLUS', description:'Document ter staving van duurzaam verblijf van een EU onderdaan'},
        17 => {id:17, code: 'FOREIGNER_F', description:'Kaart voor niet-EU familieleden van een EU-onderdaan of van een Belg. Verblijfskaart van een familielid van een burger van de Unie'},
        18 => {id:18, code: 'FOREIGNER_F_PLUS', description:'Duurzame verblijfskaart van een familielid van een burger van de Unie'},
        19 => {id:19, code: 'EUROPEAN_BLUE_CARD_H', description:' H. Europese blauwe kaart. Toegang en verblijf voor onderdanen van derde landen.'}
    }

    document_type.default = {id:0, code:'UNKNOWN', description:'Onbekende kaart'}

    {
        card_number: id.card_number,
        chip_number: id.chip_number,
        card_validity_date_begin: Time.at(id.card_validity_date_begin.time.time/1000),
        card_validity_date_end: Time.at(id.card_validity_date_end.time.time/1000),
        card_delivery_municipality: id.card_delivery_municipality,
        national_number: id.national_number,
        name: id.name,
        first_name: id.first_name,
        middle_name: id.middle_name,
        nationality: id.nationality,
        place_of_birth: id.place_of_birth,
        date_of_birth: Time.at(id.date_of_birth.time.time/1000),
        gender: id.gender.to_s,
        noble_condition: id.nobleCondition,
        document_type: document_type[id.documentType.key],
        special_status: {
            has_bad_sight: id.special_status.has_bad_sight,
            has_white_cane:  id.special_status.has_white_cane,
            has_yellow_cane: id.special_status.has_yellow_cane,
            has_extended_minority: id.special_status.has_extended_minority
        },
        duplicate: id.duplicate || '',
        is_member_of_family: id.member_of_family,
        special_organisation: special_organization[(id.special_organisation.nil? ? 0 : id.special_organisation.key)],
        date_and_country_of_protection: id.date_and_country_of_protection || ''
    }
  end

  def address
    address = TlvParser.parse(@active_card.readFile(FileType::Address), Address)

    {
        street_and_number: address.street_and_number,
        zip:address.zip,
        city: address.municipality
    }
  end

  def photo
    unless @active_card.nil?
      photo_image = javax.imageio.ImageIO.read(java.io.ByteArrayInputStream.new(@active_card.read_file(FileType::Photo)))

      unless photo_image.nil?
        grey_photo_image = java.awt.image.BufferedImage.new(photo_image.width, photo_image.height, java.awt.image.BufferedImage::TYPE_BYTE_GRAY)
        g = grey_photo_image.graphics
        g.drawImage(photo_image, 0, 0, nil)
        g.dispose()

        #javax.imageio.ImageIO.write(grey_photo_image, "png", java.io.File.new('photo.png'))

        b64 = StringIO.new
        javax.imageio.ImageIO.write(grey_photo_image, "png", b64.to_outputstream)

        b64.rewind
        return "data:image/png;base64,#{Base64.encode64(b64.readlines.join())}"
      end
    end
    return ''
  rescue Exception => e
    puts e.message
    return ''
  end
end
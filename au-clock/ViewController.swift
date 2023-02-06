//
//  ViewController.swift
//  au-clock
//
//  Created by Ryan Johnson on 1/31/23.
//
import AVFoundation
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var timeRemaining: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var countDownTimer: UIDatePicker!
    
    var timer : Timer?
    var duration : Duration?
    var player : AVAudioPlayer?
   
    @IBOutlet weak var background: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(currentDateAndTime), userInfo: nil, repeats: true)
        countDownTimer.backgroundColor = UIColor.white
    }
    
    @objc func currentDateAndTime() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM YYYY HH:mm:ss"
        let hour = Calendar.current.component(.hour, from: date)
        
        dateTime.text = "\(dateFormatter.string(from: date))"
        if(hour >= 12) {
            background.image = UIImage(named: "Afternoon")
        } else {
            background.image = UIImage(named: "Morning")
        }
    }

    @IBAction func timerButton(_ sender: UIButton) {
        duration = Duration.seconds(Int(countDownTimer.countDownDuration))
        if let buttonLabel = sender.titleLabel?.text {
            if (buttonLabel == "Start Timer") {
                startTimerAndSetButtonTitle("Stop Timer")
            } else if (buttonLabel == "Stop Timer") {
                stopTimerAndSetButtonTitle("Start Timer")
            } else if (buttonLabel == "Stop Music") {
               stopMusic()
            }
        }
    }
    
    @objc func countdown() {
        guard let d = duration else { return }
        if (d != Duration.seconds(0)) {
            duration = d - Duration.seconds(1)
            let style = Duration.TimeFormatStyle(pattern: .hourMinuteSecond(padHourToLength: 2))
            timeRemaining.text = "Time remaining: \(duration!.formatted(style))"
        } else {
            stopTimerAndSetButtonTitle("Stop Music")
            playMusic()
        }
    }
    
    func startTimerAndSetButtonTitle(_ title : String?) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        timerButton.setTitle(title, for: .normal)
    }
    
    func stopTimerAndSetButtonTitle(_ title : String?) {
        timerButton.setTitle(title, for: .normal)
        timer?.invalidate()
        timer = nil
    }
    
    func playMusic() {
        guard let url = Bundle.main.url(forResource: "Guitar Song", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }
            player.play()
            Timer.scheduledTimer(timeInterval: player.duration, target: self, selector: #selector(stopMusic), userInfo: nil, repeats: false)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func stopMusic() {
        guard let player = player else { return }
        player.stop()
        timerButton.setTitle("Start Timer", for: .normal)
    }
}

